import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/pagination.dart';
import '../data/tasks_repository_impl.dart';
import '../domain/task.dart';
import '../domain/tasks_repository.dart';

final tasksListControllerProvider =
    NotifierProvider<TasksListController, AsyncValue<Paginated<Task>>>(TasksListController.new);

final selectedCategoryIdProvider =
    NotifierProvider<SelectedCategoryIdController, int?>(SelectedCategoryIdController.new);

class SelectedCategoryIdController extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? id) => state = id;
}

final taskDetailProvider = FutureProvider.family<Task, int>((ref, id) {
  return ref.watch(tasksRepositoryProvider).getById(id);
});

final categoryOptionsProvider = FutureProvider<List<CategoryOption>>((ref) {
  return ref.watch(tasksRepositoryProvider).categories(perPage: 200);
});

final taskMutationControllerProvider =
    Provider<TaskMutationController>((ref) => TaskMutationController(ref.watch(tasksRepositoryProvider)));

class TasksListController extends Notifier<AsyncValue<Paginated<Task>>> {
  var _started = false;
  TasksRepository get _repository => ref.read(tasksRepositoryProvider);

  @override
  AsyncValue<Paginated<Task>> build() {
    if (!_started) {
      _started = true;
      Future.microtask(loadFirstPage);
    }
    return const AsyncValue.loading();
  }

  Future<void> loadFirstPage() async {
    state = const AsyncValue.loading();
    final categoryId = ref.read(selectedCategoryIdProvider);
    state = await AsyncValue.guard(() => _repository.list(page: 1, perPage: 15, categoryId: categoryId));
  }

  Future<void> loadNextPage() async {
    final current = state.asData?.value;
    if (current == null || !current.hasNextPage) {
      return;
    }

    final categoryId = ref.read(selectedCategoryIdProvider);
    final next = await _repository.list(
      page: current.currentPage + 1,
      perPage: current.perPage,
      categoryId: categoryId,
    );

    state = AsyncValue.data(
      Paginated<Task>(
        items: [...current.items, ...next.items],
        currentPage: next.currentPage,
        lastPage: next.lastPage,
        perPage: next.perPage,
        total: next.total,
      ),
    );
  }
}

class TaskMutationController {
  TaskMutationController(this._repository);

  final TasksRepository _repository;

  Future<void> apply({required int taskId, required TaskApplicationPayload payload}) {
    return _repository.apply(taskId: taskId, payload: payload);
  }

  Future<Task> create(TaskPayload payload, {List<TaskImageAttachment>? images}) {
    return _repository.create(payload, images: images);
  }

  Future<Task> update({
    required int id,
    required TaskPayload payload,
    List<TaskImageAttachment>? images,
  }) {
    return _repository.update(id: id, payload: payload, images: images);
  }

  Future<void> delete(int id) => _repository.delete(id);
}
