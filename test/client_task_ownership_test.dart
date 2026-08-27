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
import 'package:lem3alam_mobile/src/features/tasks/data/tasks_api.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/tasks_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/task.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/tasks_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/task_list_screen.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/tasks_controller.dart';

AuthState _identity(int id) => AuthState(
    status: AuthStatus.authenticated,
    user: User(
        id: id,
        name: 'Client $id',
        email: 'test@example.com',
        role: 'client',
        status: 'active',
        city: 'Rabat'));

class _Auth extends AuthController {
  @override
  AuthState build() => _identity(10);
  void change(int id) => state = _identity(id);
  void signOut() => state = AuthState.unauthenticated;
}

Map<String, dynamic> _taskJson(int id, int? owner) => {
      'id': id,
      'client_id': owner,
      'title': 'Owned task $id',
      'description': '',
      'category_id': 1,
      'city': 'Rabat',
      'budget_min': 100,
      'budget_max': 150,
      'budget_type': 'fixed',
      'urgency': 'medium',
      'status': 'open',
    };
Paginated<Task> _page(int owner, {int page = 1, int last = 1}) => Paginated(
    items: [Task.fromJson(_taskJson(owner * 10 + page, owner))],
    currentPage: page,
    lastPage: last,
    perPage: 1,
    total: last);

class _Repo implements TasksRepository {
  _Repo(this.fetch, {this.detail});
  final Future<Paginated<Task>> Function(int page) fetch;
  final Future<Task> Function(int id)? detail;
  @override
  Future<Paginated<Task>> list(
          {required int page, required int perPage, int? categoryId}) =>
      fetch(page);
  @override
  Future<Task> getById(int id) => detail!(id);
  @override
  Future<List<CategoryOption>> categories({required int perPage}) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('client list and details reject foreign or missing owners', () async {
    final dio = Dio();
    addTearDown(() => dio.close(force: true));
    int? owner = 20;
    final paths = <String>[];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      paths.add(options.path);
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'success': true,
        'data': options.path == 'my-tasks'
            ? {
                'data': [_taskJson(1, 10), _taskJson(2, owner)],
                'current_page': 1,
                'last_page': 1,
                'per_page': 15,
                'total': 2,
              }
            : _taskJson(2, owner),
      }));
    }));
    final repo = TasksRepositoryImpl(
        api: TasksApi(ApiClient(dio)),
        readAuthState: () => _identity(10),
        expireSession: () async {});
    for (final value in [20, null]) {
      owner = value;
      await expectLater(
          repo.list(page: 1, perPage: 15), throwsA(isA<ApiException>()));
      await expectLater(repo.getById(2), throwsA(isA<ApiException>()));
    }
    owner = 10;
    expect((await repo.list(page: 1, perPage: 15)).items.length, 2);
    expect((await repo.getById(2)).clientId, 10);
    expect(paths, isNot(contains('tasks')));
  });

  test('late unauthorized response does not log out the new client', () async {
    final dio = Dio();
    addTearDown(() => dio.close(force: true));
    var auth = _identity(10);
    var expired = 0;
    final pending = Completer<RequestInterceptorHandler>();
    late RequestOptions request;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      request = options;
      pending.complete(handler);
    }));
    final repo = TasksRepositoryImpl(
        api: TasksApi(ApiClient(dio)),
        readAuthState: () => auth,
        expireSession: () async {
          expired++;
        });
    final result = repo.list(page: 1, perPage: 15);
    final assertion = expectLater(result, throwsA(isA<ApiException>()));
    final handler = await pending.future;
    auth = _identity(20);
    handler.reject(DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: request, statusCode: 401)));
    await assertion;
    expect(expired, 0);
  });

  test('switching clients ignores a late first page and clears logout data',
      () async {
    final first = Completer<Paginated<Task>>();
    late ProviderContainer container;
    container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      tasksRepositoryProvider.overrideWithValue(_Repo((_) {
        final id = container.read(authControllerProvider).user!.id;
        return id == 10 ? first.future : Future.value(_page(id));
      })),
    ]);
    addTearDown(container.dispose);
    container.listen(tasksListControllerProvider, (_, next) {});
    await Future<void>.delayed(Duration.zero);
    container.read(selectedCategoryIdProvider.notifier).set(4);
    final auth = container.read(authControllerProvider.notifier) as _Auth;
    auth.change(20);
    expect(container.read(tasksListControllerProvider).isLoading, true);
    expect(container.read(selectedCategoryIdProvider), isNull);
    await Future<void>.delayed(Duration.zero);
    first.complete(_page(10));
    await Future<void>.delayed(Duration.zero);
    expect(
        container
            .read(tasksListControllerProvider)
            .requireValue
            .items
            .single
            .clientId,
        20);
    auth.signOut();
    expect(container.read(tasksListControllerProvider).asData, isNull);
  });

  test('pagination cannot append previous account rows or duplicate requests',
      () async {
    final oldNext = Completer<Paginated<Task>>();
    var nextCalls = 0;
    late ProviderContainer container;
    container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      tasksRepositoryProvider.overrideWithValue(_Repo((page) {
        final id = container.read(authControllerProvider).user!.id;
        if (id == 10 && page == 2) {
          nextCalls++;
          return oldNext.future;
        }
        return Future.value(_page(id, last: 2));
      })),
    ]);
    addTearDown(container.dispose);
    container.listen(tasksListControllerProvider, (_, next) {});
    await Future<void>.delayed(Duration.zero);
    final controller = container.read(tasksListControllerProvider.notifier);
    final pending = controller.loadNextPage();
    await controller.loadNextPage();
    expect(nextCalls, 1);
    (container.read(authControllerProvider.notifier) as _Auth).change(20);
    expect(container.read(tasksListControllerProvider).asData, isNull);
    await Future<void>.delayed(Duration.zero);
    oldNext.complete(_page(10, page: 2, last: 2));
    await pending;
    expect(
        container
            .read(tasksListControllerProvider)
            .requireValue
            .items
            .single
            .clientId,
        20);
  });

  test('task details refetch for each account', () async {
    var calls = 0;
    late ProviderContainer container;
    container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      tasksRepositoryProvider
          .overrideWithValue(_Repo((_) async => _page(10), detail: (id) async {
        calls++;
        if (container.read(authControllerProvider).user!.id != 10) {
          throw const ApiException(statusCode: 403, message: 'err_forbidden');
        }
        return Task.fromJson(_taskJson(id, 10));
      })),
    ]);
    addTearDown(container.dispose);
    container.listen(taskDetailProvider(1), (_, next) {});
    await container.read(taskDetailProvider(1).future);
    (container.read(authControllerProvider.notifier) as _Auth).change(20);
    expect(container.read(taskDetailProvider(1)).isLoading, true);
    await expectLater(container.read(taskDetailProvider(1).future),
        throwsA(isA<ApiException>()));
    expect(calls, 2);
  });

  for (final locale in [
    const Locale('en'),
    const Locale('fr'),
    const Locale('ar')
  ]) {
    testWidgets('client list labels own tasks in ${locale.languageCode}',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_Auth.new),
            tasksRepositoryProvider
                .overrideWithValue(_Repo((_) async => _page(10))),
          ],
          child: MaterialApp(
            theme: locale.languageCode == 'ar'
                ? AppTheme.dark()
                : AppTheme.light(),
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const TaskListScreen(),
          )));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(TaskListScreen));
      final l10n = AppLocalizations.of(context)!;
      expect(find.text(l10n.clientTasksTitle), findsWidgets);
      expect(find.text(l10n.recommendedForYou), findsNothing);
      await tester.scrollUntilVisible(find.text('Owned task 101'), 250,
          scrollable: find
              .descendant(
                  of: find.byType(CustomScrollView),
                  matching: find.byType(Scrollable))
              .first);
      expect(find.text('Owned task 101'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
