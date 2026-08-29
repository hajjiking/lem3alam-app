import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/taskers_repository_impl.dart';
import '../domain/tasker_own_profile.dart';
import '../domain/taskers_repository.dart';

final taskerOwnProfileProvider = FutureProvider.autoDispose
    .family<TaskerOwnProfileData, int>((ref, taskerId) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.user?.isTasker != true || auth.user?.id != taskerId) {
    throw StateError('Own tasker profile is private');
  }
  final repository = ref.watch(taskersRepositoryProvider);
  final profile = await repository.getProfile(taskerId);
  final page = await repository.reviews(
      taskerId: taskerId,
      page: 1,
      perPage: 10,
      query: const TaskerReviewsQuery(sort: 'newest'));
  if (ref.read(authControllerProvider).user?.id != taskerId) {
    throw StateError('Profile request superseded');
  }
  return TaskerOwnProfileData(
      profile: profile, reviews: List.unmodifiable(page.items));
}, retry: (_, __) => null);
