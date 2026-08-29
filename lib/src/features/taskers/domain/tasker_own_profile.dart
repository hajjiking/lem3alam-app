import 'tasker_profile.dart';
import 'tasker_review.dart';

class TaskerOwnProfileData {
  const TaskerOwnProfileData({required this.profile, required this.reviews});
  final TaskerProfile profile;
  final List<TaskerReview> reviews;
}

enum ProfileBadgeKind { topPerformer, trustedTasker, fiveStarRated }
