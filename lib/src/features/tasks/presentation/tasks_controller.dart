import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/pagination.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../data/tasks_repository_impl.dart';
import '../domain/task.dart';
import '../domain/tasks_repository.dart';

final tasksListControllerProvider =
    NotifierProvider<TasksListController, AsyncValue<Paginated<Task>>>(
        TasksListController.new);

final selectedCategoryIdProvider =
    NotifierProvider<SelectedCategoryIdController, int?>(
        SelectedCategoryIdController.new);

class SelectedCategoryIdController extends Notifier<int?> {
  @override
  int? build() {
    ref.watch(authControllerProvider
        .select((auth) => (auth.status, auth.user?.id, auth.user?.role)));
    return null;
  }

  void set(int? id) => state = id;
}

final taskDetailProvider = FutureProvider.family<Task, int>((ref, id) {
  ref.watch(authControllerProvider
      .select((auth) => (auth.status, auth.user?.id, auth.user?.role)));
  return ref.watch(tasksRepositoryProvider).getById(id);
}, retry: (count, error) => null);

final categoryOptionsProvider = FutureProvider<List<CategoryOption>>((ref) {
  return ref.watch(tasksRepositoryProvider).categories(perPage: 200);
});

final taskMutationControllerProvider = Provider<TaskMutationController>(
    (ref) => TaskMutationController(ref.watch(tasksRepositoryProvider)));

class TasksListController extends Notifier<AsyncValue<Paginated<Task>>> {
  var _requestVersion = 0;
  bool _loadingNextPage = false;
  TasksRepository get _repository => ref.read(tasksRepositoryProvider);

  @override
  AsyncValue<Paginated<Task>> build() {
    final identity = ref.watch(authControllerProvider
        .select((auth) => (auth.status, auth.user?.id, auth.user?.role)));
    ref.watch(tasksRepositoryProvider);
    final version = ++_requestVersion;
    _loadingNextPage = false;
    ref.onDispose(() => _requestVersion++);
    if (identity.$1 == AuthStatus.authenticated) {
      Future.microtask(() {
        if (ref.mounted && version == _requestVersion) {
          loadFirstPage();
        }
      });
    }
    return const AsyncValue.loading();
  }

  Future<void> loadFirstPage() async {
    if (ref.read(authControllerProvider).status != AuthStatus.authenticated) {
      return;
    }
    final version = ++_requestVersion;
    _loadingNextPage = false;
    state = const AsyncValue.loading();
    final categoryId = ref.read(selectedCategoryIdProvider);
    final result = await AsyncValue.guard(
        () => _repository.list(page: 1, perPage: 15, categoryId: categoryId));
    if (ref.mounted && version == _requestVersion) {
      state = result;
    }
  }

  Future<void> loadNextPage() async {
    final current = state.asData?.value;
    if (current == null || !current.hasNextPage || _loadingNextPage) {
      return;
    }

    final version = _requestVersion;
    _loadingNextPage = true;
    final categoryId = ref.read(selectedCategoryIdProvider);
    try {
      final next = await _repository.list(
        page: current.currentPage + 1,
        perPage: current.perPage,
        categoryId: categoryId,
      );

      if (!ref.mounted || version != _requestVersion) return;
      state = AsyncValue.data(
        Paginated<Task>(
          items: [...current.items, ...next.items],
          currentPage: next.currentPage,
          lastPage: next.lastPage,
          perPage: next.perPage,
          total: next.total,
        ),
      );
    } catch (error, stack) {
      if (ref.mounted && version == _requestVersion) {
        state = AsyncValue.error(error, stack);
      }
    } finally {
      if (version == _requestVersion) _loadingNextPage = false;
    }
  }
}

class TaskMutationController {
  TaskMutationController(this._repository);

  final TasksRepository _repository;

  Future<void> apply(
      {required int taskId, required TaskApplicationPayload payload}) {
    return _repository.apply(taskId: taskId, payload: payload);
  }

  Future<Task> create(TaskPayload payload,
      {List<TaskImageAttachment>? images}) {
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
