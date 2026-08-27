import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/pagination.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/tasks_api.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/tasks_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/task.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/tasks_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/task_list_screen.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/tasks_controller.dart';
import 'package:lem3alam_mobile/src/presentation/splash/splash_controller.dart';
import 'package:lem3alam_mobile/src/routing/app_router.dart';

const auth = AuthState(
    status: AuthStatus.authenticated,
    user: User(
        id: 20,
        name: 'Tasker',
        email: 'test@example.com',
        role: 'tasker',
        status: 'active',
        city: 'Rabat'));

class _Auth extends AuthController {
  @override
  AuthState build() => auth;
}

class _Ready extends SplashController {
  @override
  SplashState build() =>
      const SplashState(isReady: true, targetLocation: '/tasks');
}

Map<String, dynamic> taskJson(int id) => {
      'id': id,
      'client_id': 100 + id,
      'title': 'Open task $id',
      'description': '',
      'location': 'Casablanca',
      'budget_min': 100,
      'budget_max': 150,
      'budget_type': 'fixed',
      'status': 'open',
      'urgency': 'low',
    };

class _Repo implements TasksRepository {
  final requests = <int>[];
  @override
  Future<Paginated<Task>> list(
      {required int page, required int perPage, int? categoryId}) async {
    requests.add(page);
    return Paginated(
        items: [Task.fromJson(taskJson(1)), Task.fromJson(taskJson(2))],
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 2);
  }

  @override
  Future<List<CategoryOption>> categories({required int perPage}) async => [];
  @override
  Future<Task> getById(int id) async => Task.fromJson(taskJson(id));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('tasker uses unrestricted tasks endpoint and appends all API pages',
      () async {
    final dio = Dio();
    addTearDown(() => dio.close(force: true));
    final requests = <RequestOptions>[];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      final page = options.queryParameters['page'] as int;
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'success': true,
        'data': {
          'current_page': page,
          'last_page': 2,
          'per_page': 15,
          'total': 2,
          'data': [taskJson(page)]
        },
      }));
    }));
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      tasksRepositoryProvider.overrideWithValue(TasksRepositoryImpl(
          api: TasksApi(ApiClient(dio)),
          readAuthState: () => auth,
          expireSession: () async {})),
    ]);
    addTearDown(container.dispose);
    final loaded = Completer<void>();
    container.listen(tasksListControllerProvider, (_, next) {
      if (next.hasValue && !loaded.isCompleted) loaded.complete();
    });
    await loaded.future;
    await container.read(tasksListControllerProvider.notifier).loadNextPage();
    final page = container.read(tasksListControllerProvider).requireValue;
    expect(page.items.map((task) => task.clientId), [101, 102]);
    expect(page.total, 2);
    expect(requests.map((request) => request.path), ['tasks', 'tasks']);
    expect(requests.map((request) => request.queryParameters), [
      {'page': 1, 'per_page': 15},
      {'page': 2, 'per_page': 15},
    ]);
  });

  for (final code in ['en', 'fr', 'ar']) {
    testWidgets(
        'tasker Tasks route shows open feed and no posting CTA in $code',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = _Repo();
      final container = ProviderContainer(overrides: [
        authControllerProvider.overrideWith(_Auth.new),
        splashControllerProvider.overrideWith(_Ready.new),
        tasksRepositoryProvider.overrideWithValue(repo),
      ]);
      final router = container.read(goRouterProvider);
      addTearDown(router.dispose);
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
              routerConfig: router,
              theme: code == 'ar' ? AppTheme.dark() : AppTheme.light(),
              locale: Locale(code),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates:
                  AppLocalizations.localizationsDelegates)));
      await tester.pumpAndSettle();
      expect(find.byType(TaskListScreen), findsOneWidget);
      final l10n =
          AppLocalizations.of(tester.element(find.byType(TaskListScreen)))!;
      expect(find.text(l10n.taskerBrowseInfo), findsOneWidget);
      expect(find.text(l10n.bookNow), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      await tester.scrollUntilVisible(find.text(l10n.taskerAvailableTasks), 200,
          scrollable: find
              .descendant(
                  of: find.byType(CustomScrollView),
                  matching: find.byType(Scrollable))
              .first);
      expect(find.text(l10n.tasksAvailableCount(2)), findsOneWidget);
      await tester.scrollUntilVisible(
          find.text(l10n.taskerViewAndApply).first, 200,
          scrollable: find
              .descendant(
                  of: find.byType(CustomScrollView),
                  matching: find.byType(Scrollable))
              .first);
      await tester.tap(find.text(l10n.taskerViewAndApply).first);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/tasks/1');
      expect(find.text(l10n.apply), findsOneWidget);
      expect(repo.requests, [1]);
      expect(tester.takeException(), isNull);
    });
  }
}
