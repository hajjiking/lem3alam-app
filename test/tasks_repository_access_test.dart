import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/tasks_api.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/tasks_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/task.dart';

void main() {
  group('TasksRepositoryImpl access control', () {
    test('guest list request is blocked before hitting the API', () async {
      final api = _FakeTasksApi();
      final repository = TasksRepositoryImpl(
        api: api,
        readAuthState: () => AuthState.unauthenticated,
        expireSession: () async {},
      );

      await expectLater(
        () => repository.list(page: 1, perPage: 15),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403)),
      );
      expect(api.listCalls, 0);
      expect(api.myTasksCalls, 0);
    });

    test('client task list uses the private my-tasks endpoint', () async {
      final api = _FakeTasksApi();
      final repository = TasksRepositoryImpl(
        api: api,
        readAuthState: () => AuthState(
          status: AuthStatus.authenticated,
          user: const User(
            id: 10,
            name: 'Client User',
            email: 'client@example.com',
            role: 'client',
            status: 'active',
            city: 'Casablanca',
          ),
        ),
        expireSession: () async {},
      );

      final page = await repository.list(page: 1, perPage: 15);

      expect(api.listCalls, 0);
      expect(api.myTasksCalls, 1);
      expect(page.items, hasLength(1));
      expect(page.items.first.title, 'Client task');
    });

    test('tasker task list uses the published tasks endpoint', () async {
      final api = _FakeTasksApi();
      final repository = TasksRepositoryImpl(
        api: api,
        readAuthState: () => AuthState(
          status: AuthStatus.authenticated,
          user: const User(
            id: 20,
            name: 'Tasker User',
            email: 'tasker@example.com',
            role: 'tasker',
            status: 'active',
            city: 'Rabat',
          ),
        ),
        expireSession: () async {},
      );

      final page = await repository.list(page: 1, perPage: 15);

      expect(api.listCalls, 1);
      expect(api.myTasksCalls, 0);
      expect(page.items, hasLength(1));
      expect(page.items.first.title, 'Published task');
    });

    test('client cannot apply to tasks from the mobile repository', () async {
      final api = _FakeTasksApi();
      final repository = TasksRepositoryImpl(
        api: api,
        readAuthState: () => AuthState(
          status: AuthStatus.authenticated,
          user: const User(
            id: 10,
            name: 'Client User',
            email: 'client@example.com',
            role: 'client',
            status: 'active',
            city: 'Casablanca',
          ),
        ),
        expireSession: () async {},
      );

      await expectLater(
        () => repository.apply(
          taskId: 1,
          payload: const TaskApplicationPayload(
            proposal: 'Ready to help',
            proposedBudget: 250,
            estimatedDuration: '2 days',
          ),
        ),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403)),
      );
      expect(api.applyCalls, 0);
    });
  });
}

class _FakeTasksApi extends TasksApi {
  _FakeTasksApi() : super(ApiClient(Dio()));

  int listCalls = 0;
  int myTasksCalls = 0;
  int applyCalls = 0;

  @override
  Future<Map<String, dynamic>> list({
    required int page,
    required int perPage,
    int? categoryId,
  }) async {
    listCalls += 1;
    return _pageResponse(title: 'Published task');
  }

  @override
  Future<Map<String, dynamic>> myTasks({
    required int page,
    required int perPage,
    int? categoryId,
  }) async {
    myTasksCalls += 1;
    return _pageResponse(title: 'Client task');
  }

  @override
  Future<Map<String, dynamic>> apply(int id, Object payload) async {
    applyCalls += 1;
    return {'success': true};
  }

  Map<String, dynamic> _pageResponse({required String title}) {
    return {
      'success': true,
      'data': {
        'current_page': 1,
        'last_page': 1,
        'per_page': 15,
        'total': 1,
        'data': [
          {
            'id': 1,
            'title': title,
            'description': 'Task description',
            'category_id': 1,
            'city': 'Casablanca',
            'budget_min': 100,
            'budget_max': 200,
            'budget_type': 'fixed',
            'urgency': 'medium',
            'status': 'open',
          },
        ],
      },
    };
  }
}
