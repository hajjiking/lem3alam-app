import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/networking/pagination.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/task.dart';

final taskerAssignmentsRepositoryProvider =
    Provider((ref) => TaskerAssignmentsRepository(
          api: ref.watch(apiClientProvider),
          auth: () => ref.read(authControllerProvider),
          expireSession: () =>
              ref.read(authControllerProvider.notifier).expireSession(),
        ));

final taskerAssignmentsProvider = FutureProvider.autoDispose<List<Task>>((ref) {
  final identity = ref.watch(authControllerProvider
      .select((state) => (state.status, state.user?.id, state.user?.role)));
  if (identity.$1 != AuthStatus.authenticated || identity.$3 != 'tasker') {
    throw const ApiException(statusCode: 403, message: 'err_forbidden');
  }
  return ref.watch(taskerAssignmentsRepositoryProvider).active();
}, retry: (_, __) => null);

class TaskerAssignmentsRepository {
  TaskerAssignmentsRepository(
      {required this.api, required this.auth, required this.expireSession});
  final ApiClient api;
  final AuthState Function() auth;
  final Future<void> Function() expireSession;

  int _tasker() {
    final state = auth();
    if (state.status != AuthStatus.authenticated ||
        state.user?.isTasker != true) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    return state.user!.id;
  }

  void _sameTasker(int id) {
    if (_tasker() != id) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
  }

  Future<Map<String, dynamic>> _request(
      int id, Future<Map<String, dynamic>> Function() send) async {
    try {
      final response = await send();
      _sameTasker(id);
      if (response['success'] != true ||
          response['data'] is! Map<String, dynamic>) {
        throw const ApiException(message: 'err_unknown');
      }
      return response['data'] as Map<String, dynamic>;
    } on ApiException catch (error) {
      final user = auth().user;
      if (error.statusCode == 401 && user?.id == id && user?.isTasker == true) {
        await expireSession();
      }
      rethrow;
    }
  }

  Future<List<Task>> active() async {
    final id = _tasker();
    final tasks = <int, Task>{};
    // The dashboard's recent-tasks feed is capped and also includes applications.
    // Use the private assignments feed and every page for an accurate count.
    for (var page = 1;; page++) {
      _sameTasker(id);
      final data = await _request(
          id,
          () => api.getJson<Map<String, dynamic>>('tasker/assignments',
              queryParameters: {'page': page, 'per_page': 50}));
      if (data['data'] is! List) {
        throw const ApiException(message: 'err_unknown');
      }
      final result =
          Paginated.fromLaravel<Task>(data, itemFromJson: Task.fromJson);
      if (result.currentPage != page) {
        throw const ApiException(message: 'err_unknown');
      }
      for (final task in result.items) {
        if (task.assignedTaskerId != id || !task.isActiveAssignment) {
          throw const ApiException(statusCode: 403, message: 'err_forbidden');
        }
        tasks[task.id] = task;
      }
      if (!result.hasNextPage) break;
    }
    return tasks.values.toList(growable: false);
  }

  Future<Task> requestCompletion(Task task) async {
    final id = _tasker();
    if (task.assignedTaskerId != id || !task.isActiveAssignment) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    final data = await _request(
        id,
        () => api.postJson<Map<String, dynamic>>(
            'tasks/${task.id}/submit-completion'));
    final updated = Task.fromJson(data);
    if (updated.id != task.id ||
        updated.assignedTaskerId != id ||
        !updated.isActiveAssignment ||
        updated.completionRequestedAt == null) {
      throw const ApiException(message: 'err_unknown');
    }
    return updated;
  }
}
