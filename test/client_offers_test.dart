import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/core/networking/pagination.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/client_offers_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/client_completion_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/task.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/tasks_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/client_offers_panel.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/tasks_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/dashboard/application/client_dashboard_controller.dart';
import 'package:lem3alam_mobile/src/features/dashboard/domain/dashboard_models.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/client_dashboard_screen.dart';
import 'package:lem3alam_mobile/src/routing/app_router.dart';

AuthState _identity([int id = 10, String role = 'client']) => AuthState(
    status: AuthStatus.authenticated,
    user: User(
        id: id,
        name: 'Client',
        email: 'test@example.com',
        role: role,
        status: 'active',
        city: 'Rabat'));

class _Auth extends AuthController {
  @override
  AuthState build() => _identity();
  void change(int id) => state = _identity(id);
}

Task _task(
        {int id = 19,
        int owner = 10,
        String status = 'open',
        String offerStatus = 'pending',
        bool verified = true}) =>
    Task.fromJson({
      'id': id,
      'client_id': owner,
      'title': 'Repair sink',
      'status': status,
      'applications': [
        {
          'id': id * 10,
          'task_id': id,
          'tasker_id': 20,
          'tasker': {'name': 'Mohammed', 'is_verified': verified},
          'proposal': 'I can repair this sink tomorrow.',
          'proposed_budget': '120.50',
          'estimated_duration': '2 hours',
          'status': offerStatus,
        }
      ],
    });

class _Tasks implements TasksRepository {
  Task detail = _task();
  final requestedPages = <int>[];
  List<Task> items = [_task()];
  Future<void> Function()? beforeDetail;
  Future<void> Function()? beforeList;
  @override
  Future<Task> getById(int id) async {
    await beforeDetail?.call();
    return detail;
  }

  @override
  Future<Paginated<Task>> list(
      {required int page, required int perPage, int? categoryId}) async {
    requestedPages.add(page);
    await beforeList?.call();
    return Paginated(
        items: items.isEmpty ? [] : [items[page - 1]],
        currentPage: page,
        lastPage: items.isEmpty ? 1 : items.length,
        perPage: 1,
        total: items.length);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Api extends ApiClient {
  _Api() : super(Dio());
  final paths = <String>[];
  Future<void> Function()? result;
  @override
  Future<T> putJson<T>(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    paths.add(path);
    await result?.call();
    return {'success': true} as T;
  }
}

ClientOffersRepository _repo(_Tasks tasks, _Api api,
        {AuthState Function()? auth}) =>
    ClientOffersRepository(
        tasks: tasks,
        api: api,
        auth: auth ?? _identity,
        expireSession: () async {});

ClientOffer _entry(Task task) => ClientOffer(task, task.offers.single);

Future<void> _pump(WidgetTester tester, ClientOffersRepository repo,
    {String language = 'en', Widget? home}) async {
  await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_Auth.new),
        clientOffersRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
            body: SingleChildScrollView(
                child: home ?? const ClientOffersPanel())),
      )));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'client dashboard opens received proposal details and tasker profile',
      (tester) async {
    final tasks = _Tasks();
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const ClientDashboardScreen()),
      GoRoute(
          path: '/tasks/:id',
          name: AppRouteNames.taskDetail,
          builder: (_, state) =>
              TaskDetailScreen(taskId: int.parse(state.pathParameters['id']!))),
      GoRoute(
          path: '/taskers/:id',
          name: AppRouteNames.taskerProfile,
          builder: (_, state) => Scaffold(
              body: Text('Tasker profile ${state.pathParameters['id']}'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_Auth.new),
          clientDashboardProvider
              .overrideWith((ref) async => DashboardSnapshot.empty),
          clientCompletionProvider.overrideWith((ref) async => []),
          tasksRepositoryProvider.overrideWithValue(tasks),
          clientOffersRepositoryProvider
              .overrideWithValue(_repo(tasks, _Api())),
        ],
        child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.light(),
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates)));
    await tester.pumpAndSettle();
    expect(find.text('New offers waiting (1)'), findsOneWidget);
    final l10n =
        AppLocalizations.of(tester.element(find.byType(ClientOffersPanel)))!;
    await tester.ensureVisible(find.text(l10n.taskDetails));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.taskDetails));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('I can repair this sink tomorrow.'), findsOneWidget);
    await tester.ensureVisible(find.text(l10n.viewProfile));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.viewProfile));
    await tester.pumpAndSettle();
    expect(find.text('Tasker profile 20'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('account change replaces pending offer data instead of retaining it',
      () async {
    final tasks = _Tasks();
    late ProviderContainer container;
    container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      clientOffersRepositoryProvider.overrideWithValue(_repo(tasks, _Api(),
          auth: () => container.read(authControllerProvider))),
    ]);
    addTearDown(container.dispose);
    final sub = container.listen(clientOffersProvider, (_, __) {});
    addTearDown(sub.close);
    expect(
        (await container.read(clientOffersProvider.future))
            .single
            .task
            .clientId,
        10);
    final load = Completer<void>();
    tasks.beforeList = () => load.future;
    tasks.items = [_task(owner: 11)];
    (container.read(authControllerProvider.notifier) as _Auth).change(11);
    final next = container.read(clientOffersProvider.future);
    expect(container.read(clientOffersProvider).isLoading, isTrue);
    load.complete();
    expect((await next).single.task.clientId, 11);
  });

  test('parses real proposal, decimal budget, duration and verified flag', () {
    final offer = _task().offers.single;
    expect(offer.budget, 120.5);
    expect(offer.duration, '2 hours');
    expect(offer.taskerName, 'Mohammed');
    expect(offer.verified, isTrue);
    expect(_task(verified: false).offers.single.verified, isFalse);
  });

  test('loads every owned-task page and counts only actionable pending offers',
      () async {
    final tasks = _Tasks()
      ..items = [
        _task(),
        _task(id: 21, status: 'assigned'),
        _task(id: 22, offerStatus: 'rejected'),
        _task(id: 23),
      ];
    final offers = await _repo(tasks, _Api()).pending();
    expect(tasks.requestedPages, [1, 2, 3, 4]);
    expect(offers.map((entry) => entry.offer.id), [190, 230]);
  });

  test('blocks guests, taskers and foreign-client tasks', () async {
    final tasks = _Tasks();
    for (final auth in [AuthState.unauthenticated, _identity(20, 'tasker')]) {
      await expectLater(_repo(tasks, _Api(), auth: () => auth).pending(),
          throwsA(isA<ApiException>()));
    }
    expect(tasks.requestedPages, isEmpty);
    tasks.items = [_task(owner: 11)];
    await expectLater(
        _repo(tasks, _Api()).pending(), throwsA(isA<ApiException>()));
  });

  test('rejects old account responses while loading offers', () async {
    var auth = _identity();
    final tasks = _Tasks()
      ..beforeList = () async {
        auth = _identity(11);
      };
    await expectLater(_repo(tasks, _Api(), auth: () => auth).pending(),
        throwsA(isA<ApiException>()));
  });

  test('accept and reject use the existing PUT application endpoints',
      () async {
    final api = _Api();
    final repo = _repo(_Tasks(), api);
    await repo.decide(_entry(_task()), accept: true);
    await repo.decide(_entry(_task()), accept: false);
    expect(api.paths, ['applications/190/accept', 'applications/190/reject']);
  });

  test('stale, foreign and account-switched offers never send a mutation',
      () async {
    final tasks = _Tasks();
    final api = _Api();
    var auth = _identity();
    final repo = _repo(tasks, api, auth: () => auth);
    await expectLater(repo.decide(_entry(_task(owner: 11)), accept: true),
        throwsA(isA<ApiException>()));
    tasks.detail = _task(status: 'assigned');
    await expectLater(repo.decide(_entry(_task()), accept: true),
        throwsA(isA<ApiException>()));
    tasks.detail = _task(offerStatus: 'rejected');
    await expectLater(repo.decide(_entry(_task()), accept: true),
        throwsA(isA<ApiException>()));
    tasks.detail = _task();
    tasks.beforeDetail = () async {
      auth = _identity(11);
    };
    await expectLater(repo.decide(_entry(_task()), accept: true),
        throwsA(isA<ApiException>()));
    expect(api.paths, isEmpty);
  });

  for (final language in ['en', 'fr', 'ar']) {
    testWidgets('API offers render on compact $language screens',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pump(tester, _repo(_Tasks(), _Api()), language: language);
      final l10n =
          AppLocalizations.of(tester.element(find.byType(ClientOffersPanel)))!;
      expect(find.text(l10n.clientOffersWaiting(1)), findsOneWidget);
      expect(find.text('Mohammed'), findsOneWidget);
      expect(find.text('I can repair this sink tomorrow.'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final accept in [true, false]) {
    testWidgets(
        '${accept ? 'accept' : 'reject'} confirms, submits once and refreshes offers',
        (tester) async {
      final tasks = _Tasks();
      final api = _Api();
      final result = Completer<void>();
      api.result = () async {
        await result.future;
        tasks.items = [];
      };
      await _pump(tester, _repo(tasks, api));
      final label = accept ? 'Accept' : 'Reject';
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(api.paths, isEmpty);
      await tester.tap(find
          .descendant(of: find.byType(AlertDialog), matching: find.text(label))
          .last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(api.paths, hasLength(1));
      final buttons =
          tester.widgetList<FilledButton>(find.byType(FilledButton));
      expect(buttons.every((button) => button.onPressed == null), isTrue);
      result.complete();
      await tester.pumpAndSettle();
      expect(find.text('New offers waiting (0)'), findsOneWidget);
      expect(find.text('Mohammed'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cancel confirmation sends nothing; server failure allows retry',
      (tester) async {
    final api = _Api()
      ..result = () async =>
          throw const ApiException(message: 'err_server', statusCode: 500);
    await _pump(tester, _repo(_Tasks(), api));
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(api.paths, isEmpty);
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    await tester.tap(find
        .descendant(of: find.byType(AlertDialog), matching: find.text('Accept'))
        .last);
    await tester.pumpAndSettle();
    expect(find.text('New offers waiting (1)'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('load errors are not shown as zero offers and retry recovers',
      (tester) async {
    final tasks = _Tasks()
      ..beforeList =
          () async => throw const ApiException(message: 'err_server');
    await _pump(tester, _repo(tasks, _Api()));
    expect(find.text('New offers waiting (0)'), findsNothing);
    expect(find.text('Could not load your offers. Please try again.'),
        findsOneWidget);
    tasks.beforeList = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('New offers waiting (1)'), findsOneWidget);
  });

  testWidgets(
      'task details hide other clients proposals and closed-task actions',
      (tester) async {
    await _pump(tester, _repo(_Tasks(), _Api()),
        home: TaskOffersSection(task: _task(owner: 11)));
    expect(find.text('Mohammed'), findsNothing);
    await _pump(tester, _repo(_Tasks(), _Api()),
        home: TaskOffersSection(
            task: _task(status: 'assigned', offerStatus: 'accepted')));
    expect(find.text('Mohammed'), findsOneWidget);
    expect(find.text('Offer accepted'), findsOneWidget);
    expect(find.text('Accept'), findsNothing);
    expect(find.text('Reject'), findsNothing);
  });
}
