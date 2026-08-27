import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/client_reviews_repository.dart';
import '../domain/task.dart';
import 'client_review_sheet.dart';

class ClientReviewsPanel extends ConsumerWidget {
  const ClientReviewsPanel({super.key, this.taskerId, this.onSelect});
  final int? taskerId;
  final ValueChanged<Task>? onSelect;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user?.isClient != true) return const SizedBox.shrink();
    final l10n = context.l10n;
    return AppSectionCard(
        title: l10n.leaveReview,
        subtitle: l10n.shareYourExperience,
        child: ref.watch(clientReviewableTasksProvider).when(
              skipLoadingOnRefresh: false,
              skipLoadingOnReload: false,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Column(children: [
                Text(l10n.reviewTasksLoadError),
                TextButton(
                    onPressed: () =>
                        ref.invalidate(clientReviewableTasksProvider),
                    child: Text(l10n.retry))
              ]),
              data: (all) {
                final tasks = all
                    .where((t) =>
                        t.clientId == user!.id &&
                        (taskerId == null || t.assignedTaskerId == taskerId))
                    .toList();
                if (tasks.isEmpty) return Text(l10n.noReviewableTasks);
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final task in tasks)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(task.title),
                          subtitle:
                              Text(task.assignedTaskerName ?? l10n.tasker),
                          trailing: const Icon(Icons.rate_review_outlined),
                          onTap: () {
                            if (onSelect != null) {
                              onSelect!(task);
                            } else {
                              showClientReviewSheet(context, ref, task);
                            }
                          },
                        ),
                    ]);
              },
            ));
  }
}

class ClientTaskReviewSection extends ConsumerWidget {
  const ClientTaskReviewSection({super.key, required this.task});
  final Task task;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user?.isClient != true ||
        task.clientId != user?.id ||
        task.status != 'completed' ||
        task.assignedTaskerId == null) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    return AppSectionCard(
        title: l10n.leaveReview,
        child: ref.watch(clientTaskReviewProvider(task.id)).when(
              skipLoadingOnReload: false,
              skipLoadingOnRefresh: false,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Column(children: [
                Text(l10n.reviewTasksLoadError),
                TextButton(
                    onPressed: () =>
                        ref.invalidate(clientTaskReviewProvider(task.id)),
                    child: Text(l10n.retry))
              ]),
              data: (state) {
                final review = state.review;
                if (review != null) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.reviewAlreadySubmitted),
                        Text(l10n.reviewStars(review.rating)),
                        const SizedBox(height: 8),
                        Text(review.comment),
                      ]);
                }
                if (!state.canReview) return Text(l10n.reviewUnavailable);
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.shareYourExperience),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                          onPressed: () =>
                              showClientReviewSheet(context, ref, state.task),
                          icon: const Icon(Icons.rate_review_outlined),
                          label: Text(l10n.leaveReview)),
                    ]);
              },
            ));
  }
}
