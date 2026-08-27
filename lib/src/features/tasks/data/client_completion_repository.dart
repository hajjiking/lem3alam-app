import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/networking/pagination.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/task.dart';

final clientCompletionRepositoryProvider =
    Provider((ref) => ClientCompletionRepository(
          api: ref.watch(apiClientProvider),
          auth: () => ref.read(authControllerProvider),
          expireSession: () =>
              ref.read(authControllerProvider.notifier).expireSession(),
        ));

final clientCompletionProvider = FutureProvider.autoDispose<List<Task>>((ref) {
  final identity = ref.watch(authControllerProvider
      .select((state) => (state.status, state.user?.id, state.user?.role)));
  if (identity.$1 != AuthStatus.authenticated || identity.$3 != 'client') {
    throw const ApiException(statusCode: 403, message: 'err_forbidden');
  }
  return ref.watch(clientCompletionRepositoryProvider).pending();
}, retry: (_, __) => null);

class ClientCompletionRepository {
  ClientCompletionRepository(
      {required this.api, required this.auth, required this.expireSession});
  final ApiClient api;
  final AuthState Function() auth;
  final Future<void> Function() expireSession;

  int _client() {
    final state = auth();
    if (state.status != AuthStatus.authenticated ||
        state.user?.isClient != true) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    return state.user!.id;
  }

  Future<Map<String, dynamic>> _request(
      int id, Future<Map<String, dynamic>> Function() send) async {
    try {
      final response = await send();
      if (_client() != id) {
        throw const ApiException(statusCode: 403, message: 'err_forbidden');
      }
      if (response['success'] != true ||
          response['data'] is! Map<String, dynamic>) {
        throw const ApiException(message: 'err_unknown');
      }
      return response['data'] as Map<String, dynamic>;
    } on ApiException catch (error) {
      final user = auth().user;
      if (error.statusCode == 401 && user?.id == id && user?.isClient == true) {
        await expireSession();
      }
      rethrow;
    }
  }

  Future<List<Task>> pending() async {
    final id = _client();
    final tasks = <int, Task>{};
    for (var page = 1;; page++) {
      if (_client() != id) {
        throw const ApiException(statusCode: 403, message: 'err_forbidden');
      }
      final data = await _request(
          id,
          () => api.getJson<Map<String, dynamic>>('client/completion-requests',
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
        if (task.clientId != id || !task.awaitsCompletionApproval) {
          throw const ApiException(statusCode: 403, message: 'err_forbidden');
        }
        tasks[task.id] = task;
      }
      if (!result.hasNextPage) break;
    }
    return tasks.values.toList(growable: false);
  }

  Future<Task> decide(Task task, {required bool approve}) async {
    final id = _client();
    if (task.clientId != id || !task.awaitsCompletionApproval) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    final data = await _request(
        id,
        () => api.postJson<Map<String, dynamic>>(
                'tasks/${task.id}/${approve ? 'approve' : 'decline'}-completion',
                data: {
                  'completion_requested_at':
                      task.completionRequestedAt!.toUtc().toIso8601String()
                }));
    final updated = Task.fromJson(data);
    if (updated.id != task.id ||
        updated.clientId != id ||
        updated.status != (approve ? 'completed' : 'in_progress') ||
        updated.completionRequestedAt != null) {
      throw const ApiException(message: 'err_unknown');
    }
    return updated;
  }
}
