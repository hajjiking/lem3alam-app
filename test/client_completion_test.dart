import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/dashboard/application/client_dashboard_controller.dart';
import 'package:lem3alam_mobile/src/features/dashboard/domain/dashboard_models.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/client_dashboard_screen.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/client_completion_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/client_reviews_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/client_offers_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/tasks_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/task.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/tasks_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/client_completion_panel.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:lem3alam_mobile/src/routing/app_router.dart';

AuthState _identity([int id = 10, String role = 'client']) => AuthState(
      status: AuthStatus.authenticated,
      user: User(
          id: id,
          name: 'Amina',
          email: 'test@example.com',
          role: role,
          status: 'active',
          city: 'Rabat'),
    );

class _Auth extends AuthController {
  @override
  AuthState build() => _identity();
  void change(int id) => state = _identity(id);
}

Map<String, dynamic> _task(
        {int id = 19,
        int owner = 10,
        String status = 'in_progress',
        bool pending = true}) =>
    {
      'id': id,
      'client_id': owner,
      'assigned_tasker_id': 20,
      'assigned_tasker': {'id': 20, 'name': 'Mohammed'},
      'title': 'Repair sink $id',
      'status': status,
      'completion_requested_at': pending ? '2026-08-27T10:00:00Z' : null,
    };

class _Api extends ApiClient {
  _Api() : super(Dio());
  List<Map<String, dynamic>> items = [_task()];
  final gets = <(String, int)>[];
  final posts = <(String, Object?)>[];
  Future<void> Function()? onGet;
  Future<void> Function()? onPost;
  @override
  Future<T> getJson<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final page = queryParameters!['page'] as int;
    gets.add((path, page));
    await onGet?.call();
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
    items = [];
    return {
      'success': true,
      'data': _task(
          status: path.contains('/approve-') ? 'completed' : 'in_progress',
          pending: false)
    } as T;
  }
}

class _Tasks implements TasksRepository {
  @override
  Future<Task> getById(int id) async => Task.fromJson(_task(id: id));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ClientCompletionRepository _repo(_Api api,
        {AuthState Function()? auth, Future<void> Function()? expire}) =>
    ClientCompletionRepository(
        api: api,
        auth: auth ?? _identity,
        expireSession: expire ?? () async {});

Future<void> _pump(WidgetTester tester, ClientCompletionRepository repo,
    {String language = 'en', bool dark = false, Widget? child}) async {
  await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_Auth.new),
        clientCompletionRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
            body: SingleChildScrollView(
                child: child ?? const ClientCompletionPanel())),
      )));
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find
      .descendant(of: find.byType(AlertDialog), matching: find.text(label))
      .last);
  await tester.pump();
}

void main() {
  test('loads all private pending pages', () async {
    final api = _Api()..items = [_task(), _task(id: 21)];
    expect(await _repo(api).pending(), hasLength(2));
    expect(api.gets,
        [('client/completion-requests', 1), ('client/completion-requests', 2)]);
  });
  test('blocks guests, taskers, foreign and non-pending tasks before decisions',
      () async {
    final api = _Api();
    for (final auth in [AuthState.unauthenticated, _identity(20, 'tasker')]) {
      await expectLater(
          _repo(api, auth: () => auth).pending(), throwsA(isA<ApiException>()));
      await expectLater(
          _repo(api, auth: () => auth)
              .decide(Task.fromJson(_task()), approve: true),
          throwsA(isA<ApiException>()));
    }
    expect(api.gets, isEmpty);
    for (final data in [
      _task(owner: 11),
      _task(pending: false),
      _task(status: 'completed')
    ]) {
      api.items = [data];
      await expectLater(_repo(api).pending(), throwsA(isA<ApiException>()));
      await expectLater(_repo(api).decide(Task.fromJson(data), approve: true),
          throwsA(isA<ApiException>()));
    }
    expect(api.posts, isEmpty);
  });
  for (final approve in [true, false]) {
    test(
        '${approve ? 'approve' : 'decline'} posts the reviewed request timestamp and maps new state',
        () async {
      final api = _Api();
      final updated =
          await _repo(api).decide(Task.fromJson(_task()), approve: approve);
      expect(api.posts.single.$1,
          'tasks/19/${approve ? 'approve' : 'decline'}-completion');
      expect(api.posts.single.$2,
          {'completion_requested_at': '2026-08-27T10:00:00.000Z'});
      expect(updated.status, approve ? 'completed' : 'in_progress');
      expect(updated.completionRequestedAt, isNull);
    });
    testWidgets(
        '${approve ? 'approve' : 'return'} confirms once, disables duplicate actions and refreshes count',
        (tester) async {
      final api = _Api();
      final result = Completer<void>();
      api.onPost = () => result.future;
      await _pump(tester, _repo(api));
      await _confirm(
          tester, approve ? 'Approve completion' : 'Return for changes');
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.posts, hasLength(1));
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull);
      result.complete();
      await tester.pumpAndSettle();
      expect(find.text('Completion approval (0)'), findsOneWidget);
      expect(find.text('Approve completion'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  test('old responses and old unauthorized errors do not affect new account',
      () async {
    var auth = _identity();
    var expired = false;
    final api = _Api()
      ..onGet = () async {
        auth = _identity(11);
      };
    final repo = _repo(api,
        auth: () => auth,
        expire: () async {
          expired = true;
        });
    await expectLater(repo.pending(), throwsA(isA<ApiException>()));
    auth = _identity();
    api.onPost = () async {
      auth = _identity(11);
      throw const ApiException(statusCode: 401, message: 'err_unauthorized');
    };
    await expectLater(repo.decide(Task.fromJson(_task()), approve: true),
        throwsA(isA<ApiException>()));
    expect(expired, isFalse);
  });
  test('switching client account reloads its pending tasks', () async {
    final api = _Api();
    late ProviderContainer container;
    container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      clientCompletionRepositoryProvider.overrideWithValue(
          _repo(api, auth: () => container.read(authControllerProvider))),
    ]);
    addTearDown(container.dispose);
    final sub = container.listen(clientCompletionProvider, (_, __) {});
    addTearDown(sub.close);
    expect(
        (await container.read(clientCompletionProvider.future)).single.clientId,
        10);
    api.items = [_task(owner: 11)];
    (container.read(authControllerProvider.notifier) as _Auth).change(11);
    expect(
        (await container.read(clientCompletionProvider.future)).single.clientId,
        11);
  });
  for (final language in ['en', 'fr', 'ar']) {
    testWidgets('compact $language approval layout', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pump(tester, _repo(_Api()),
          language: language, dark: language == 'ar');
      final l10n = AppLocalizations.of(
          tester.element(find.byType(ClientCompletionPanel)))!;
      expect(find.text(l10n.completionApprovalCount(1)), findsOneWidget);
      expect(find.text(l10n.approveCompletion), findsOneWidget);
      expect(find.text(l10n.returnForChanges), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('cancel makes no request; failed action keeps decision retryable',
      (tester) async {
    final api = _Api()
      ..onPost = () async =>
          throw const ApiException(message: 'err_server', statusCode: 500);
    await _pump(tester, _repo(api));
    await tester.tap(find.text('Approve completion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(api.posts, isEmpty);
    await _confirm(tester, 'Approve completion');
    await tester.pumpAndSettle();
    expect(find.text('Completion approval (1)'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull);
    api.onPost = null;
    await _confirm(tester, 'Approve completion');
    await tester.pumpAndSettle();
    expect(find.text('Completion approval (0)'), findsOneWidget);
  });
  testWidgets('stale request refreshes without showing approval success',
      (tester) async {
    final api = _Api();
    api.onPost = () async {
      api.items = [];
      throw const ApiException(statusCode: 409, message: 'changed');
    };
    await _pump(tester, _repo(api));
    await _confirm(tester, 'Approve completion');
    await tester.pumpAndSettle();
    expect(find.text('Completion approval (0)'), findsOneWidget);
    expect(find.text('Completion approved'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('load failure has retry and does not fabricate zero approvals',
      (tester) async {
    final api = _Api()
      ..onGet = () async => throw const ApiException(message: 'err_server');
    await _pump(tester, _repo(api));
    expect(find.text('Completion approval (0)'), findsNothing);
    api.onGet = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Completion approval (1)'), findsOneWidget);
  });
  testWidgets('late response after leaving screen is safe', (tester) async {
    final api = _Api();
    final result = Completer<void>();
    api.onPost = () => result.future;
    await _pump(tester, _repo(api));
    await _confirm(tester, 'Approve completion');
    await tester.pumpWidget(const MaterialApp(home: Text('Other screen')));
    result.complete();
    await tester.pumpAndSettle();
    expect(find.text('Other screen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('foreign-client task never displays decision controls',
      (tester) async {
    await _pump(tester, _repo(_Api()),
        child: ClientCompletionCard(task: Task.fromJson(_task(owner: 11))));
    expect(find.text('Approve completion'), findsNothing);
  });
  testWidgets('client dashboard opens real task details with approval actions',
      (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const ClientDashboardScreen()),
      GoRoute(
          path: '/tasks/:id',
          name: AppRouteNames.taskDetail,
          builder: (_, state) =>
              TaskDetailScreen(taskId: int.parse(state.pathParameters['id']!))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_Auth.new),
          clientCompletionRepositoryProvider.overrideWithValue(_repo(_Api())),
          clientOffersProvider.overrideWith((ref) async => []),
          clientReviewableTasksProvider.overrideWith((ref) async => []),
          clientDashboardProvider
              .overrideWith((ref) async => DashboardSnapshot.empty),
          tasksRepositoryProvider.overrideWithValue(_Tasks()),
        ],
        child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.light(),
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates)));
    await tester.pumpAndSettle();
    expect(find.text('Completion approval (1)'), findsOneWidget);
    await tester.ensureVisible(find.text('Task details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Task details'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('Approve completion'), findsOneWidget);
    expect(find.text('Return for changes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
