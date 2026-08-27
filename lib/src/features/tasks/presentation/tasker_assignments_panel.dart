import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../data/tasker_assignments_repository.dart';
import '../domain/task.dart';
import 'tasks_controller.dart';

class TaskerAssignmentsPanel extends ConsumerWidget {
  const TaskerAssignmentsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user?.isTasker != true) return const SizedBox.shrink();
    final l10n = context.l10n;
    return ref.watch(taskerAssignmentsProvider).when(
          skipLoadingOnReload: false,
          skipLoadingOnRefresh: false,
          loading: () => AppSectionCard(
              title: l10n.activeAssignmentsTitle,
              child: const Center(child: CircularProgressIndicator())),
          error: (_, __) => AppSectionCard(
              title: l10n.activeAssignmentsTitle,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.assignmentsLoadError),
                    TextButton.icon(
                        onPressed: () =>
                            ref.invalidate(taskerAssignmentsProvider),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry)),
                  ])),
          data: (tasks) =>
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l10n.activeAssignmentsCount(tasks.length),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(l10n.activeAssignmentsSubtitle),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              AppSectionCard(child: Text(l10n.noActiveAssignments)),
            for (final task in tasks)
              Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TaskerAssignmentCard(
                      key: ValueKey('assignment-${user!.id}-${task.id}'),
                      task: task)),
          ]),
        );
  }
}

class TaskerAssignmentCard extends ConsumerStatefulWidget {
  const TaskerAssignmentCard(
      {super.key, required this.task, this.showDetails = true});
  final Task task;
  final bool showDetails;
  @override
  ConsumerState<TaskerAssignmentCard> createState() =>
      _TaskerAssignmentCardState();
}

class _TaskerAssignmentCardState extends ConsumerState<TaskerAssignmentCard> {
  bool _busy = false;
  bool _sending = false;
  Task? _updated;

  @override
  void didUpdateWidget(covariant TaskerAssignmentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.task, oldWidget.task)) _updated = null;
  }

  Future<void> _request() async {
    if (_busy) return;
    final task = _updated ?? widget.task;
    final userId = ref.read(authControllerProvider).user?.id;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
                title: Text(l10n.requestCompletion),
                content: Text(l10n.confirmRequestCompletion(task.title)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(l10n.cancel)),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: Text(l10n.requestCompletion)),
                ],
              ));
      if (!mounted || confirmed != true) return;
      final user = ref.read(authControllerProvider).user;
      if (user?.id != userId || user?.isTasker != true) return;
      setState(() => _sending = true);
      final updated = await ref
          .read(taskerAssignmentsRepositoryProvider)
          .requestCompletion(task);
      if (!mounted) return;
      final current = ref.read(authControllerProvider).user;
      if (current?.id != userId || current?.isTasker != true) return;
      setState(() => _updated = updated);
      ref.invalidate(taskerAssignmentsProvider);
      ref.invalidate(taskDetailProvider(task.id));
      ref.invalidate(dashboardControllerProvider);
      if (messenger.mounted) {
        messenger
            .showSnackBar(SnackBar(content: Text(l10n.completionRequestSent)));
      }
    } catch (error) {
      if (!mounted || ref.read(authControllerProvider).user?.id != userId) {
        return;
      }
      final message = error is ApiException
          ? error.statusCode == 409
              ? l10n.assignmentNoLongerActive
              : localizeApiException(context, error)
          : l10n.errUnknown;
      if (messenger.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final task = _updated ?? widget.task;
    if (user?.isTasker != true ||
        task.assignedTaskerId != user?.id ||
        !task.isActiveAssignment) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final waiting = task.completionRequestedAt != null;
    final numbers = NumberFormat.decimalPattern(l10n.localeName);
    return AppSectionCard(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(task.title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      if (task.clientName?.isNotEmpty == true)
        Text('${l10n.client}: ${task.clientName}'),
      if (task.city.isNotEmpty) Text(task.city),
      const SizedBox(height: 8),
      Text(l10n.dashboardPrice(task.budgetMin == task.budgetMax
          ? numbers.format(task.budgetMin)
          : '${numbers.format(task.budgetMin)} – ${numbers.format(task.budgetMax)}')),
      const SizedBox(height: 8),
      Text(
          waiting
              ? l10n.awaitingClientApproval
              : task.status == 'assigned'
                  ? l10n.statusAssigned
                  : l10n.statusInProgress,
          style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        if (widget.showDetails)
          OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => context.goNamed(AppRouteNames.taskDetail,
                      pathParameters: {'id': '${task.id}'}),
              child: Text(l10n.taskDetails)),
        if (!waiting)
          FilledButton.icon(
              onPressed: _busy ? null : _request,
              icon: const Icon(Icons.task_alt),
              label: Text(l10n.requestCompletion)),
      ]),
      if (_sending)
        const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator()),
    ]));
  }
}
