import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/pagination.dart';
import '../domain/tasker_profile.dart';
import '../domain/tasker_review.dart';
import '../domain/taskers_repository.dart';
import 'taskers_api.dart';

final taskersRepositoryProvider = Provider<TaskersRepository>((ref) {
  return TaskersRepositoryImpl(api: TaskersApi(ref.watch(apiClientProvider)));
});

class TaskersRepositoryImpl implements TaskersRepository {
  TaskersRepositoryImpl({required this.api});

  final TaskersApi api;

  @override
  Future<TaskerProfile> getProfile(int taskerId) async {
    final json = await api.show(taskerId);
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return TaskerProfile.fromJson(data);
  }

  @override
  Future<Paginated<TaskerReview>> reviews({
    required int taskerId,
    required int page,
    required int perPage,
    required TaskerReviewsQuery query,
  }) async {
    final json = await api.reviews(
      id: taskerId,
      page: page,
      perPage: perPage,
      queryParameters: query.toQueryParameters(),
    );

    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    final reviewsRaw = data['reviews'];
    if (reviewsRaw is Map<String, dynamic>) {
      return Paginated.fromLaravel<TaskerReview>(
        reviewsRaw,
        itemFromJson: TaskerReview.fromJson,
      );
    }
    return Paginated(
        items: const [],
        currentPage: 1,
        lastPage: 1,
        perPage: perPage,
        total: 0);
  }
}
