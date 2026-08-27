import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/networking/pagination.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/task.dart';

class ClientTaskReview {
  ClientTaskReview.fromJson(Map<String, dynamic> json)
      : id = int.tryParse('${json['id']}') ?? 0,
        taskId = int.tryParse('${json['task_id']}') ?? 0,
        clientId = int.tryParse('${json['client_id']}') ?? 0,
        taskerId = int.tryParse('${json['tasker_id']}') ?? 0,
        rating = int.tryParse('${json['rating']}') ?? 0,
        comment = (json['comment'] ?? '').toString(),
        status = (json['status'] ?? '').toString();
  final int id, taskId, clientId, taskerId, rating;
  final String comment, status;
}

class TaskReviewStatus {
  const TaskReviewStatus(
      {required this.task, required this.canReview, this.review});
  final Task task;
  final bool canReview;
  final ClientTaskReview? review;
}

final clientReviewsRepositoryProvider =
    Provider((ref) => ClientReviewsRepository(
          api: ref.watch(apiClientProvider),
          auth: () => ref.read(authControllerProvider),
          expireSession: () =>
              ref.read(authControllerProvider.notifier).expireSession(),
        ));
void _watchClient(Ref ref) {
  final identity = ref.watch(authControllerProvider
      .select((s) => (s.status, s.user?.id, s.user?.role)));
  if (identity.$1 != AuthStatus.authenticated || identity.$3 != 'client') {
    throw const ApiException(statusCode: 403, message: 'err_forbidden');
  }
}

final clientReviewableTasksProvider =
    FutureProvider.autoDispose<List<Task>>((ref) {
  _watchClient(ref);
  return ref.watch(clientReviewsRepositoryProvider).eligible();
}, retry: (_, __) => null);
final clientTaskReviewProvider =
    FutureProvider.autoDispose.family<TaskReviewStatus, int>((ref, id) {
  _watchClient(ref);
  return ref.watch(clientReviewsRepositoryProvider).status(id);
}, retry: (_, __) => null);

class ClientReviewsRepository {
  ClientReviewsRepository(
      {required this.api, required this.auth, required this.expireSession});
  final ApiClient api;
  final AuthState Function() auth;
  final Future<void> Function() expireSession;
  int _client() {
    final s = auth();
    if (s.status != AuthStatus.authenticated || s.user?.isClient != true) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    return s.user!.id;
  }

  Future<Map<String, dynamic>> _request(
      int id, Future<Map<String, dynamic>> Function() send) async {
    try {
      final result = await send();
      if (_client() != id) {
        throw const ApiException(statusCode: 403, message: 'err_forbidden');
      }
      if (result['success'] != true ||
          result['data'] is! Map<String, dynamic>) {
        throw const ApiException(message: 'err_unknown');
      }
      return result['data'] as Map<String, dynamic>;
    } on ApiException catch (e) {
      final user = auth().user;
      if (e.statusCode == 401 && user?.id == id && user?.isClient == true) {
        await expireSession();
      }
      rethrow;
    }
  }

  bool _eligible(Task task, int id) =>
      task.clientId == id &&
      task.status == 'completed' &&
      task.assignedTaskerId != null &&
      task.assignedTaskerId != id;
  void _validateReview(ClientTaskReview review, Task task, int id) {
    if (review.id <= 0 ||
        review.taskId != task.id ||
        review.clientId != id ||
        review.taskerId != task.assignedTaskerId ||
        review.rating < 1 ||
        review.rating > 5) {
      throw const ApiException(message: 'err_unknown');
    }
  }

  Future<List<Task>> eligible() async {
    final id = _client();
    final tasks = <int, Task>{};
    for (var page = 1;; page++) {
      if (_client() != id) {
        throw const ApiException(statusCode: 403, message: 'err_forbidden');
      }
      final data = await _request(
          id,
          () => api.getJson<Map<String, dynamic>>('client/reviewable-tasks',
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
        if (!_eligible(task, id)) {
          throw const ApiException(statusCode: 403, message: 'err_forbidden');
        }
        tasks[task.id] = task;
      }
      if (!result.hasNextPage) break;
    }
    return tasks.values.toList(growable: false);
  }

  Future<TaskReviewStatus> status(int taskId) async {
    final id = _client();
    final data = await _request(
        id, () => api.getJson<Map<String, dynamic>>('tasks/$taskId/my-review'));
    final task = Task.fromJson(data['task'] as Map<String, dynamic>);
    if (task.id != taskId || task.clientId != id) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    final review = data['review'] is Map<String, dynamic>
        ? ClientTaskReview.fromJson(data['review'] as Map<String, dynamic>)
        : null;
    if (review != null) _validateReview(review, task, id);
    return TaskReviewStatus(
        task: task,
        review: review,
        canReview: data['can_review'] == true &&
            review == null &&
            _eligible(task, id));
  }

  Future<ClientTaskReview> submit(Task task,
      {required int rating,
      required String comment,
      required String locale}) async {
    final id = _client();
    if (!_eligible(task, id)) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    final text = comment.trim();
    if (rating < 1 ||
        rating > 5 ||
        text.runes.length < 20 ||
        text.runes.length > 500 ||
        !['en', 'fr', 'ar'].contains(locale)) {
      throw const ApiException(statusCode: 422, message: 'err_unknown');
    }
    final data = await _request(
        id,
        () => api.postJson<Map<String, dynamic>>('reviews', data: {
              'task_id': task.id,
              'rating': rating,
              'comment': text,
              'locale': locale,
            }));
    final review = ClientTaskReview.fromJson(data);
    _validateReview(review, task, id);
    return review;
  }
}
