import '../../../core/networking/pagination.dart';
import 'nearby_task_feed.dart';
import 'task.dart';

abstract class TasksRepository {
  Future<Paginated<Task>> list({required int page, required int perPage, int? categoryId});
  Future<Task> getById(int id);
  Future<Task> create(TaskPayload payload, {List<TaskImageAttachment>? images});
  Future<Task> update({
    required int id,
    required TaskPayload payload,
    List<TaskImageAttachment>? images,
  });
  Future<void> delete(int id);
  Future<void> apply({required int taskId, required TaskApplicationPayload payload});
  Future<NearbyTaskFeed> nearby({
    required int page,
    required int perPage,
    required int radiusKm,
    bool savedOnly,
  });
  Future<void> saveNearbyTask(int taskId);
  Future<void> unsaveNearbyTask(int taskId);
  Future<void> dismissNearbyTask(int taskId);

  Future<List<CategoryOption>> categories({required int perPage});
}
