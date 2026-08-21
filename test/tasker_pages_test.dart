import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lem3alam_mobile/src/app.dart';
import 'package:lem3alam_mobile/src/core/analytics/app_analytics.dart';
import 'package:lem3alam_mobile/src/core/networking/pagination.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/taskers/data/taskers_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/taskers/domain/tasker_profile.dart';
import 'package:lem3alam_mobile/src/features/taskers/domain/tasker_review.dart';
import 'package:lem3alam_mobile/src/features/taskers/domain/taskers_repository.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/tasker_profile_screen.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/tasker_reviews_screen.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/tasks_controller.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/task.dart';
import 'package:lem3alam_mobile/src/routing/app_router.dart';

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

class _FakeAnalytics extends AppAnalytics {
  const _FakeAnalytics();

  @override
  void track(String name, {Map<String, Object?> properties = const {}}) {}
}

class _FakeTaskersRepository implements TaskersRepository {
  @override
  Future<TaskerProfile> getProfile(int taskerId) async {
    return TaskerProfile(
      id: taskerId,
      name: 'Test Tasker',
      city: 'Casablanca',
      address: '123 Main St',
      bio: 'Bio',
      phone: '+212600000000',
      profileImage: null,
      hourlyRate: 100,
      available: true,
      isVerified: true,
      averageRating: 4.6,
      totalReviews: 12,
      skills: const [
        TaskerSkill(id: 1, name: 'Plumbing', category: 'Home', experienceLevel: 'expert', yearsExperience: 5, description: null, isVerified: true),
      ],
      portfolio: const [],
      socialAccounts: const [],
    );
  }

  @override
  Future<Paginated<TaskerReview>> reviews({
    required int taskerId,
    required int page,
    required int perPage,
    required TaskerReviewsQuery query,
  }) async {
    return Paginated(
      items: const [
        TaskerReview(
          id: 1,
          rating: 5,
          comment: 'Great',
          createdAtIso: '2026-01-01T00:00:00Z',
          reviewerName: 'Client A',
          reviewerAvatar: null,
          taskTitle: 'Fix sink',
        ),
      ],
      currentPage: 1,
      lastPage: 1,
      perPage: perPage,
      total: 1,
    );
  }
}

class _FakeTasksListController extends TasksListController {
  @override
  AsyncValue<Paginated<Task>> build() => AsyncValue.data(Paginated(items: const [], currentPage: 1, lastPage: 1, perPage: 15, total: 0));
}

void main() {
  testWidgets('Tasker profile page loads and can navigate to reviews page', (tester) async {
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(_AuthenticatedTaskerAuthController.new),
        analyticsProvider.overrideWithValue(const _FakeAnalytics()),
        taskersRepositoryProvider.overrideWithValue(_FakeTaskersRepository()),
        tasksListControllerProvider.overrideWith(_FakeTasksListController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const Lem3alamApp()));
    await tester.pumpAndSettle();

    final router = container.read(goRouterProvider);
    router.go('/taskers/2');
    await tester.pumpAndSettle();

    expect(find.byType(TaskerProfileScreen), findsOneWidget);
    expect(find.text('Tasker Profile'), findsOneWidget);
    expect(find.text('Skills', skipOffstage: false), findsOneWidget);

    final seeAll = find.widgetWithText(TextButton, 'See all');
    for (var i = 0; i < 6 && seeAll.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(seeAll, findsOneWidget);
    await tester.tap(seeAll);
    await tester.pumpAndSettle();

    expect(find.byType(TaskerReviewsScreen), findsOneWidget);
    expect(find.text('Reviews'), findsWidgets);
  });
}
