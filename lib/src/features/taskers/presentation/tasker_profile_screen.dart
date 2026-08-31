import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import 'public_tasker_profile_screen.dart';
import 'tasker_own_profile_screen.dart';

/// Route compatibility wrapper. Owners keep their private dashboard; every
/// other viewer gets the dedicated read-only public profile.
class TaskerProfileScreen extends ConsumerWidget {
  const TaskerProfileScreen({super.key, required this.taskerId});
  final int taskerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user?.isTasker == true && user?.id == taskerId) {
      return TaskerOwnProfileScreen(taskerId: taskerId);
    }
    return PublicTaskerProfileScreen(taskerId: taskerId);
  }
}
