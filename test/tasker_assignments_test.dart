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
import 'package:lem3alam_mobile/src/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/dashboard/domain/dashboard_models.dart';
import 'package:lem3alam_mobile/src/features/dashboard/domain/dashboard_repository.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/tasker_assignments_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/tasks_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/task.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/tasks_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/tasker_assignments_panel.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:lem3alam_mobile/src/routing/app_router.dart';

AuthState _identity([int id = 20, String role = 'tasker']) => AuthState(
      status: AuthStatus.authenticated,
      user: User(
          id: id,
          name: 'Mohammed',
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
        int owner = 20,
        String status = 'assigned',
        bool waiting = false}) =>
    {
      'id': id,
      'client_id': 10,
      'client': {'id': 10, 'name': 'Amina'},
      'assigned_tasker_id': owner,
      'title': 'Repair sink $id',
      'status': status,
      'city': 'Rabat',
      'budget_min': '120.50',
      'budget_max': '150.00',
      'completion_requested_at': waiting ? '2026-08-27T10:00:00Z' : null,
    };

class _Api extends ApiClient {
  _Api() : super(Dio());
  List<Map<String, dynamic>> items = [_task()];
  final gets = <(String, int)>[];
  final posts = <String>[];
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
        'total': items.length,
        'per_page': 1,
      }
    } as T;
  }

  @override
  Future<T> postJson<T>(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    posts.add(path);
    await onPost?.call();
    items = [_task(status: 'in_progress', waiting: true)];
    return {'success': true, 'data': items.single} as T;
  }
}

class _Tasks implements TasksRepository {
  @override
  Future<Task> getById(int id) async => Task.fromJson(_task(id: id));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Dashboard implements DashboardRepository {
  @override
  Future<DashboardSnapshot> fetchDashboard() async => DashboardSnapshot.empty;
}

TaskerAssignmentsRepository _repo(_Api api,
        {AuthState Function()? auth, Future<void> Function()? expire}) =>
    TaskerAssignmentsRepository(
        api: api,
        auth: auth ?? _identity,
        expireSession: expire ?? () async {});

Future<void> _pump(WidgetTester tester, TaskerAssignmentsRepository repo,
    {String language = 'en', bool dark = false, Widget? child}) async {
  await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_Auth.new),
        taskerAssignmentsRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
            body: SingleChildScrollView(
                child: child ?? const TaskerAssignmentsPanel())),
      )));
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.tap(find.text('Request completion'));
  await tester.pumpAndSettle();
  await tester.tap(find
      .descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Request completion'))
      .last);
  await tester.pump();
}

void main() {
  test(
      'loads all pages from private assignments endpoint, including pending approval',
      () async {
    final api = _Api()
      ..items = [_task(), _task(id: 21, status: 'in_progress', waiting: true)];
    final tasks = await _repo(api).active();
    expect(api.gets, [('tasker/assignments', 1), ('tasker/assignments', 2)]);
    expect(tasks, hasLength(2));
    expect(tasks.last.completionRequestedAt, isNotNull);
  });

  test('blocks guests, clients, foreign assignments and non-active tasks',
      () async {
    final api = _Api();
    for (final auth in [AuthState.unauthenticated, _identity(10, 'client')]) {
      await expectLater(
          _repo(api, auth: () => auth).active(), throwsA(isA<ApiException>()));
      await expectLater(
          _repo(api, auth: () => auth)
              .requestCompletion(Task.fromJson(_task())),
          throwsA(isA<ApiException>()));
    }
    expect(api.gets, isEmpty);
    expect(api.posts, isEmpty);
    for (final item in [
      _task(owner: 99),
      _task(status: 'open'),
      _task(status: 'completed')
    ]) {
      api.items = [item];
      await expectLater(_repo(api).active(), throwsA(isA<ApiException>()));
      await expectLater(_repo(api).requestCompletion(Task.fromJson(item)),
          throwsA(isA<ApiException>()));
    }
    expect(api.posts, isEmpty);
  });

  test('old account responses are rejected and old 401 cannot expire new login',
      () async {
    var auth = _identity();
    var expired = false;
    final api = _Api()
      ..onGet = () async {
        auth = _identity(21);
      };
    final repo = _repo(api,
        auth: () => auth,
        expire: () async {
          expired = true;
        });
    await expectLater(repo.active(), throwsA(isA<ApiException>()));
    auth = _identity();
    api.onPost = () async {
      auth = _identity(21);
      throw const ApiException(statusCode: 401, message: 'err_unauthorized');
    };
    await expectLater(repo.requestCompletion(Task.fromJson(_task())),
        throwsA(isA<ApiException>()));
    expect(expired, isFalse);
  });

  test('requests completion without marking work completed', () async {
    final api = _Api();
    final updated = await _repo(api).requestCompletion(Task.fromJson(_task()));
    expect(api.posts, ['tasks/19/submit-completion']);
    expect(updated.status, 'in_progress');
    expect(updated.completionRequestedAt, isNotNull);
  });

  test('switching accounts reloads assignments', () async {
    final api = _Api();
    late ProviderContainer container;
    container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      taskerAssignmentsRepositoryProvider.overrideWithValue(
          _repo(api, auth: () => container.read(authControllerProvider))),
    ]);
    addTearDown(container.dispose);
    final sub = container.listen(taskerAssignmentsProvider, (_, __) {});
    addTearDown(sub.close);
    expect(
        (await container.read(taskerAssignmentsProvider.future))
            .single
            .assignedTaskerId,
        20);
    api.items = [_task(owner: 21)];
    (container.read(authControllerProvider.notifier) as _Auth).change(21);
    expect(
        (await container.read(taskerAssignmentsProvider.future))
            .single
            .assignedTaskerId,
        21);
  });

  for (final language in ['en', 'fr', 'ar']) {
    testWidgets(
        'compact $language assignments render pending approval correctly',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = _Api()
        ..items = [
          _task(),
          _task(id: 21, status: 'in_progress', waiting: true)
        ];
      await _pump(tester, _repo(api),
          language: language, dark: language == 'ar');
      final l10n = AppLocalizations.of(
          tester.element(find.byType(TaskerAssignmentsPanel)))!;
      expect(find.text(l10n.activeAssignmentsCount(2)), findsOneWidget);
      expect(find.text(l10n.requestCompletion), findsOneWidget);
      expect(find.text(l10n.awaitingClientApproval), findsOneWidget);
      expect(find.text('Repair sink 19'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'confirmation cancel sends nothing and submit is guarded while pending',
      (tester) async {
    final api = _Api();
    final result = Completer<void>();
    api.onPost = () => result.future;
    await _pump(tester, _repo(api));
    await tester.tap(find.text('Request completion'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(api.posts, isEmpty);
    await _confirm(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(api.posts, hasLength(1));
    expect(
        tester
            .widget<FilledButton>(
                find.byWidgetPredicate((widget) => widget is FilledButton))
            .onPressed,
        isNull);
    result.complete();
    await tester.pumpAndSettle();
    expect(find.text('Request completion'), findsNothing);
    expect(find.text('Awaiting client approval'), findsOneWidget);
    expect(find.text('Active assignments (1)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'failed completion remains retryable and does not show approval pending',
      (tester) async {
    final api = _Api()
      ..onPost = () async =>
          throw const ApiException(statusCode: 500, message: 'err_server');
    await _pump(tester, _repo(api));
    await _confirm(tester);
    await tester.pumpAndSettle();
    expect(find.text('Awaiting client approval'), findsNothing);
    expect(
        tester
            .widget<FilledButton>(
                find.byWidgetPredicate((widget) => widget is FilledButton))
            .onPressed,
        isNotNull);
    api.onPost = null;
    await _confirm(tester);
    await tester.pumpAndSettle();
    expect(api.posts, hasLength(2));
    expect(find.text('Awaiting client approval'), findsOneWidget);
  });

  testWidgets('load failure is not a zero count and retry recovers',
      (tester) async {
    final api = _Api()
      ..onGet = () async =>
          throw const ApiException(statusCode: 404, message: 'err_not_found');
    await _pump(tester, _repo(api));
    expect(find.text('Active assignments (0)'), findsNothing);
    expect(find.text('Could not load your assignments. Please try again.'),
        findsOneWidget);
    api.onGet = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Active assignments (1)'), findsOneWidget);
  });

  testWidgets('late completion after leaving the page does not crash',
      (tester) async {
    final api = _Api();
    final result = Completer<void>();
    api.onPost = () => result.future;
    await _pump(tester, _repo(api));
    await _confirm(tester);
    await tester.pumpWidget(const MaterialApp(home: Text('Other page')));
    result.complete();
    await tester.pumpAndSettle();
    expect(find.text('Other page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'dashboard assignments open actual task details with completion action',
      (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
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
          dashboardRepositoryProvider.overrideWithValue(_Dashboard()),
          taskerAssignmentsRepositoryProvider.overrideWithValue(_repo(_Api())),
          tasksRepositoryProvider.overrideWithValue(_Tasks()),
        ],
        child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.light(),
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates)));
    await tester.pumpAndSettle();
    expect(find.text('Active assignments (1)'), findsOneWidget);
    await tester.ensureVisible(find.text('Task details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Task details'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('Request completion'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
