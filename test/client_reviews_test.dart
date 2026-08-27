import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/core/networking/pagination.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/client_reviews_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/task.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/client_reviews_panel.dart';
import 'package:lem3alam_mobile/src/features/taskers/data/taskers_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/taskers/domain/tasker_profile.dart';
import 'package:lem3alam_mobile/src/features/taskers/domain/tasker_review.dart';
import 'package:lem3alam_mobile/src/features/taskers/domain/taskers_repository.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/tasker_reviews_screen.dart';

const _comment = 'Excellent work, on time and very professional.';
AuthState _identity([int id = 10, String role = 'client']) => AuthState(
    status: AuthStatus.authenticated,
    user: User(
        id: id,
        name: 'Amina',
        email: 'test@example.com',
        role: role,
        status: 'active',
        city: 'Rabat'));

class _Auth extends AuthController {
  @override
  AuthState build() => _identity();
}

class _Taskers implements TaskersRepository {
  _Taskers(this.api);
  final _Api api;
  int profileLoads = 0;
  int reviewLoads = 0;
  @override
  Future<TaskerProfile> getProfile(int taskerId) async {
    profileLoads++;
    return TaskerProfile.fromJson({
      'id': taskerId,
      'name': 'Mohammed',
      'average_rating': api.review == null ? 0 : 4,
      'total_reviews': api.review == null ? 0 : 1
    });
  }

  @override
  Future<Paginated<TaskerReview>> reviews(
      {required int taskerId,
      required int page,
      required int perPage,
      required TaskerReviewsQuery query}) async {
    reviewLoads++;
    return Paginated(
        items: [if (api.review != null) TaskerReview.fromJson(api.review!)],
        currentPage: 1,
        lastPage: 1,
        perPage: perPage,
        total: api.review == null ? 0 : 1);
  }
}

Map<String, dynamic> _task(
        {int id = 19,
        int owner = 10,
        String status = 'completed',
        int? tasker = 20}) =>
    {
      'id': id,
      'client_id': owner,
      'assigned_tasker_id': tasker,
      'assigned_tasker': {'id': tasker, 'name': 'Mohammed'},
      'title': 'Repair sink $id',
      'status': status,
    };

class _Api extends ApiClient {
  _Api() : super(Dio());
  List<Map<String, dynamic>> items = [_task()];
  Map<String, dynamic>? review;
  final gets = <String>[];
  final posts = <(String, Object?)>[];
  Future<void> Function()? onGet;
  Future<void> Function()? onPost;
  @override
  Future<T> getJson<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    gets.add(path);
    await onGet?.call();
    if (path == 'tasks/19/my-review') {
      return {
        'success': true,
        'data': {
          'task': _task(),
          'review': review,
          'can_review': review == null
        }
      } as T;
    }
    expect(path, 'client/reviewable-tasks');
    final page = queryParameters!['page'] as int;
    return {
      'success': true,
      'data': {
        'data': items.isEmpty ? [] : [items[page - 1]],
        'current_page': page,
        'last_page': items.isEmpty ? 1 : items.length,
        'per_page': 1,
        'total': items.length,
      }
    } as T;
  }

  @override
  Future<T> postJson<T>(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    posts.add((path, data));
    await onPost?.call();
    final payload = data! as Map<String, dynamic>;
    review = {
      'id': 1,
      'task_id': payload['task_id'],
      'client_id': 10,
      'tasker_id': 20,
      'rating': payload['rating'],
      'comment': payload['comment'],
      'status': 'approved'
    };
    items = [];
    return {'success': true, 'data': review} as T;
  }
}

ClientReviewsRepository _repo(_Api api,
        {AuthState Function()? auth, Future<void> Function()? expire}) =>
    ClientReviewsRepository(
        api: api,
        auth: auth ?? _identity,
        expireSession: expire ?? () async {});
Future<void> _pump(WidgetTester tester, _Api api,
    {String language = 'en', bool panel = false}) async {
  await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_Auth.new),
        clientReviewsRepositoryProvider.overrideWithValue(_repo(api)),
      ],
      child: MaterialApp(
          theme: AppTheme.dark(),
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
              body: SingleChildScrollView(
                  child: panel
                      ? const ClientReviewsPanel()
                      : ClientTaskReviewSection(
                          task: Task.fromJson(_task())))))));
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Leave a Review').last);
  await tester.pumpAndSettle();
}

Future<void> _fill(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('review-star-4')));
  await tester.enterText(find.byType(TextFormField), _comment);
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Submit review'));
  await tester.tap(find.text('Submit review'));
  await tester.pump();
}

void main() {
  testWidgets(
      'tasker reviews page selects a matching task, saves and refreshes ratings',
      (tester) async {
    final api = _Api()..items = [_task(), _task(id: 21, tasker: 30)];
    final taskers = _Taskers(api);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_Auth.new),
          clientReviewsRepositoryProvider.overrideWithValue(_repo(api)),
          taskersRepositoryProvider.overrideWithValue(taskers),
        ],
        child: MaterialApp(
            theme: AppTheme.light(),
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const TaskerReviewsScreen(taskerId: 20))));
    await tester.pumpAndSettle();
    await _open(tester);
    expect(find.text('Repair sink 19'), findsOneWidget);
    expect(find.text('Repair sink 21'), findsNothing);
    await tester.tap(find.text('Repair sink 19'));
    await tester.pumpAndSettle();
    await _fill(tester);
    await _submit(tester);
    await tester.pumpAndSettle();
    expect(api.posts, hasLength(1));
    expect(taskers.profileLoads, 2);
    expect(taskers.reviewLoads, 2);
    expect(find.text(_comment), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  test('eligible completed tasks are paginated using private endpoint',
      () async {
    final api = _Api()..items = [_task(), _task(id: 21)];
    expect(await _repo(api).eligible(), hasLength(2));
    expect(api.gets, ['client/reviewable-tasks', 'client/reviewable-tasks']);
  });
  test('submission sends task, rating, text and locale, never caller identity',
      () async {
    final api = _Api();
    final saved = await _repo(api).submit(Task.fromJson(_task()),
        rating: 4, comment: '  $_comment  ', locale: 'en');
    expect(saved.rating, 4);
    expect(api.posts.single.$1, 'reviews');
    expect(api.posts.single.$2,
        {'task_id': 19, 'rating': 4, 'comment': _comment, 'locale': 'en'});
  });
  test('guest/tasker, foreign, unfinished and unassigned tasks cannot submit',
      () async {
    final api = _Api();
    for (final identity in [
      AuthState.unauthenticated,
      _identity(20, 'tasker')
    ]) {
      await expectLater(_repo(api, auth: () => identity).eligible(),
          throwsA(isA<ApiException>()));
      await expectLater(
          _repo(api, auth: () => identity).submit(Task.fromJson(_task()),
              rating: 4, comment: _comment, locale: 'en'),
          throwsA(isA<ApiException>()));
    }
    for (final task in [
      _task(owner: 11),
      _task(status: 'in_progress'),
      _task(tasker: null),
      _task(tasker: 10)
    ]) {
      await expectLater(
          _repo(api).submit(Task.fromJson(task),
              rating: 4, comment: _comment, locale: 'en'),
          throwsA(isA<ApiException>()));
    }
    expect(api.posts, isEmpty);
    expect(api.gets, isEmpty);
  });
  test('does not expose foreign task lists or stale account responses',
      () async {
    final api = _Api()..items = [_task(owner: 11)];
    await expectLater(_repo(api).eligible(), throwsA(isA<ApiException>()));
    var identity = _identity();
    var expired = false;
    api.onGet = () async {
      identity = _identity(11);
    };
    await expectLater(_repo(api, auth: () => identity).status(19),
        throwsA(isA<ApiException>()));
    identity = _identity();
    api.onGet = () async {
      identity = _identity(11);
      throw const ApiException(statusCode: 401, message: 'err_unauthorized');
    };
    await expectLater(
        _repo(api,
            auth: () => identity,
            expire: () async {
              expired = true;
            }).status(19),
        throwsA(isA<ApiException>()));
    expect(expired, isFalse);
  });
  testWidgets(
      'focused form saves once and displays persisted review without lifecycle errors',
      (tester) async {
    final api = _Api();
    final pending = Completer<void>();
    api.onPost = () => pending.future;
    await _pump(tester, api);
    await _open(tester);
    await _fill(tester);
    await _submit(tester);
    expect(api.posts, hasLength(1));
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text(_comment), findsOneWidget);
    expect(find.text('Your review has been submitted.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('requires rating and at least 20 characters', (tester) async {
    final api = _Api();
    await _pump(tester, api);
    await _open(tester);
    await tester.enterText(find.byType(TextFormField), 'Good');
    await _submit(tester);
    expect(api.posts, isEmpty);
    expect(find.byType(TextFormField), findsOneWidget);
    await _fill(tester);
    await _submit(tester);
    await tester.pumpAndSettle();
    expect(api.posts, hasLength(1));
  });
  testWidgets('failed request preserves feedback and allows retry',
      (tester) async {
    final api = _Api()
      ..onPost = () async {
        throw const ApiException(statusCode: 500, message: 'err_unknown');
      };
    await _pump(tester, api);
    await _open(tester);
    await _fill(tester);
    await _submit(tester);
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        _comment);
    expect(find.text('Your review has been submitted.'), findsNothing);
    api.onPost = null;
    await _submit(tester);
    await tester.pumpAndSettle();
    expect(api.posts, hasLength(2));
    expect(find.byType(TextFormField), findsNothing);
  });
  testWidgets('duplicate response disables submission without false success',
      (tester) async {
    final api = _Api()
      ..onPost = () async {
        throw const ApiException(statusCode: 409, message: 'Duplicate');
      };
    await _pump(tester, api);
    await _open(tester);
    await _fill(tester);
    await _submit(tester);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    expect(find.text('Your review has been submitted.'), findsNothing);
  });
  testWidgets('dismissing focused pending form never pops underlying screen',
      (tester) async {
    final api = _Api();
    final pending = Completer<void>();
    api.onPost = () => pending.future;
    await _pump(tester, api);
    await _open(tester);
    await _fill(tester);
    await _submit(tester);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final language in ['en', 'fr', 'ar']) {
    testWidgets(
        '$language compact dashboard panel opens review with real task data',
        (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pump(tester, _Api(), language: language, panel: true);
      await tester.tap(find.text('Repair sink 19'));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byKey(const ValueKey('review-star-5')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
