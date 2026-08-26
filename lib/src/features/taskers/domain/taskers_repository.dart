import '../../../core/networking/pagination.dart';
import 'tasker_profile.dart';
import 'tasker_review.dart';

class TaskerReviewsQuery {
  const TaskerReviewsQuery({
    this.rating,
    this.sort = 'newest',
    this.from,
    this.to,
  });

  final int? rating;
  final String sort;
  final String? from;
  final String? to;

  Map<String, dynamic> toQueryParameters() {
    return {
      if (rating != null) 'rating': rating,
      if (sort.isNotEmpty) 'sort': sort,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };
  }
}

abstract class TaskersRepository {
  Future<TaskerProfile> getProfile(int taskerId);

  Future<Paginated<TaskerReview>> reviews({
    required int taskerId,
    required int page,
    required int perPage,
    required TaskerReviewsQuery query,
  });
}
