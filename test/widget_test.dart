import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lem3alam_mobile/src/app.dart';
import 'package:lem3alam_mobile/src/core/networking/pagination.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/task.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/task_list_screen.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/tasks_controller.dart';
import 'package:lem3alam_mobile/src/routing/app_router.dart';

class _UnauthenticatedAuthController extends AuthController {
  @override
  AuthState build() => AuthState.unauthenticated;
}

class _AuthenticatedAuthController extends AuthController {
  @override
  AuthState build() {
    return AuthState(
      status: AuthStatus.authenticated,
      user: const User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        role: 'client',
        status: 'active',
        city: 'Tanger',
      ),
    );
  }
}

class _AuthenticatedTaskerAuthController extends AuthController {
  @override
  AuthState build() {
    return AuthState(
      status: AuthStatus.authenticated,
      user: const User(
        id: 2,
        name: 'Tasker User',
        email: 'tasker@example.com',
        role: 'tasker',
        status: 'active',
        city: 'Tanger',
      ),
    );
  }
}

class _FakeTasksListController extends TasksListController {
  @override
  AsyncValue<Paginated<Task>> build() {
    return AsyncValue.data(
      Paginated(
        items: const [],
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 0,
      ),
    );
  }
}

void main() {
  testWidgets('Unauthenticated: splash redirects to tasks and dashboard tab opens login', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(_UnauthenticatedAuthController.new),
        tasksListControllerProvider.overrideWith(_FakeTasksListController.new),
        taskDetailProvider.overrideWith((ref, id) async {
          return Task(
            id: id,
            title: 'Stub task $id',
            description: 'Desc',
            categoryId: 1,
            city: 'Tanger',
            budgetMin: 10,
            budgetMax: 20,
            budgetType: 'fixed',
            urgency: 'medium',
            status: 'open',
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const Lem3alamApp()));
    await tester.pumpAndSettle();

    expect(find.byType(TaskListScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Deep link: navigating to /tasks/:id shows detail and back returns to list', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(_UnauthenticatedAuthController.new),
        tasksListControllerProvider.overrideWith(_FakeTasksListController.new),
        taskDetailProvider.overrideWith((ref, id) async {
          return Task(
            id: id,
            title: 'Stub task $id',
            description: 'Desc',
            categoryId: 1,
            city: 'Tanger',
            budgetMin: 10,
            budgetMax: 20,
            budgetType: 'fixed',
            urgency: 'medium',
            status: 'open',
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const Lem3alamApp()));
    await tester.pumpAndSettle();

    final router = container.read(goRouterProvider);
    router.go('/tasks/42');
    await tester.pumpAndSettle();

    expect(find.byType(TaskDetailScreen), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    expect(find.byType(TaskListScreen), findsOneWidget);
  });

  testWidgets('Authenticated: splash redirects to dashboard and shows bottom navigation', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(_AuthenticatedAuthController.new),
        tasksListControllerProvider.overrideWith(_FakeTasksListController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const Lem3alamApp()));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('Android back from dashboard root switches to tasks tab (instead of exiting)', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(_AuthenticatedAuthController.new),
        tasksListControllerProvider.overrideWith(_FakeTasksListController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const Lem3alamApp()));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);

    final didPop = await tester.binding.handlePopRoute();
    expect(didPop, isTrue);
    await tester.pumpAndSettle();

    expect(find.byType(TaskListScreen), findsOneWidget);
  });

  testWidgets('Tasker cannot open task create route and does not see create button', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(_AuthenticatedTaskerAuthController.new),
        tasksListControllerProvider.overrideWith(_FakeTasksListController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const Lem3alamApp()));
    await tester.pumpAndSettle();

    final router = container.read(goRouterProvider);
    router.go('/tasks/create');
    await tester.pumpAndSettle();

    expect(find.byType(TaskListScreen), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('Tasker can see apply button on open task details', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(_AuthenticatedTaskerAuthController.new),
        tasksListControllerProvider.overrideWith(_FakeTasksListController.new),
        taskDetailProvider.overrideWith((ref, id) async {
          return Task(
            id: id,
            title: 'Stub task $id',
            description: 'Desc',
            categoryId: 1,
            city: 'Tanger',
            budgetMin: 10,
            budgetMax: 20,
            budgetType: 'fixed',
            urgency: 'medium',
            status: 'open',
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const Lem3alamApp()));
    await tester.pumpAndSettle();

    final router = container.read(goRouterProvider);
    router.go('/tasks/9');
    await tester.pumpAndSettle();

    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.byIcon(Icons.send_outlined), findsOneWidget);
  });
}
