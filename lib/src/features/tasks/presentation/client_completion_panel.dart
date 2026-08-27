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
import '../../dashboard/application/client_dashboard_controller.dart';
import '../data/client_completion_repository.dart';
import '../domain/task.dart';
import 'tasks_controller.dart';

class ClientCompletionPanel extends ConsumerWidget {
  const ClientCompletionPanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user?.isClient != true) return const SizedBox.shrink();
    final l10n = context.l10n;
    return ref.watch(clientCompletionProvider).when(
          skipLoadingOnReload: false,
          skipLoadingOnRefresh: false,
          loading: () => AppSectionCard(
              title: l10n.completionApprovalTitle,
              child: const Center(child: CircularProgressIndicator())),
          error: (_, __) => AppSectionCard(
              title: l10n.completionApprovalTitle,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.completionApprovalLoadError),
                    TextButton.icon(
                        onPressed: () =>
                            ref.invalidate(clientCompletionProvider),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry)),
                  ])),
          data: (tasks) =>
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l10n.completionApprovalCount(tasks.length),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(l10n.completionApprovalSubtitle),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              AppSectionCard(child: Text(l10n.noCompletionApprovals)),
            for (final task in tasks)
              Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClientCompletionCard(
                      key: ValueKey('completion-${user!.id}-${task.id}'),
                      task: task)),
          ]),
        );
  }
}

class ClientCompletionCard extends ConsumerStatefulWidget {
  const ClientCompletionCard(
      {super.key, required this.task, this.showDetails = true});
  final Task task;
  final bool showDetails;
  @override
  ConsumerState<ClientCompletionCard> createState() =>
      _ClientCompletionCardState();
}

class _ClientCompletionCardState extends ConsumerState<ClientCompletionCard> {
  bool _busy = false;
  bool _sending = false;
  bool _resolved = false;

  @override
  void didUpdateWidget(covariant ClientCompletionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.completionRequestedAt !=
            widget.task.completionRequestedAt ||
        oldWidget.task.id != widget.task.id) {
      _resolved = false;
    }
  }

  Future<void> _decide(bool approve) async {
    if (_busy || _resolved) return;
    // Capture the exact request reviewed before opening confirmation.
    final task = widget.task;
    final userId = ref.read(authControllerProvider).user?.id;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
                title: Text(
                    approve ? l10n.approveCompletion : l10n.returnForChanges),
                content: Text(approve
                    ? l10n.confirmApproveCompletion(task.title)
                    : l10n.confirmReturnForChanges(task.title)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(l10n.cancel)),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: Text(approve
                          ? l10n.approveCompletion
                          : l10n.returnForChanges)),
                ],
              ));
      if (!mounted || confirmed != true) return;
      final user = ref.read(authControllerProvider).user;
      if (user?.id != userId || user?.isClient != true) return;
      setState(() => _sending = true);
      await ref
          .read(clientCompletionRepositoryProvider)
          .decide(task, approve: approve);
      if (!mounted) return;
      final current = ref.read(authControllerProvider).user;
      if (current?.id != userId || current?.isClient != true) return;
      setState(() => _resolved = true);
      _refresh(task.id);
      if (messenger.mounted) {
        messenger.showSnackBar(SnackBar(
            content: Text(approve
                ? l10n.completionApproved
                : l10n.taskReturnedForChanges)));
      }
    } catch (error) {
      if (!mounted || ref.read(authControllerProvider).user?.id != userId) {
        return;
      }
      final stale = error is ApiException && error.statusCode == 409;
      if (stale) _refresh(task.id);
      final message = stale
          ? l10n.completionRequestChanged
          : error is ApiException
              ? localizeApiException(context, error)
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

  void _refresh(int taskId) {
    ref.invalidate(clientCompletionProvider);
    ref.invalidate(taskDetailProvider(taskId));
    ref.invalidate(tasksListControllerProvider);
    ref.invalidate(clientDashboardProvider);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final task = widget.task;
    if (_resolved ||
        user?.isClient != true ||
        task.clientId != user?.id ||
        !task.awaitsCompletionApproval) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    return AppSectionCard(
        title: widget.showDetails ? task.title : l10n.completionApprovalTitle,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (task.assignedTaskerName?.isNotEmpty == true)
            Text('${l10n.tasker}: ${task.assignedTaskerName}'),
          const SizedBox(height: 8),
          Text(l10n.completionRequestedOn(DateFormat.yMMMd(l10n.localeName)
              .add_jm()
              .format(task.completionRequestedAt!.toLocal()))),
          const SizedBox(height: 12),
          Text(l10n.completionApprovalSubtitle),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton(
                onPressed: _busy ? null : () => _decide(true),
                child: Text(l10n.approveCompletion)),
            OutlinedButton(
                onPressed: _busy ? null : () => _decide(false),
                child: Text(l10n.returnForChanges)),
            if (widget.showDetails)
              TextButton(
                  onPressed: _busy
                      ? null
                      : () => context.goNamed(AppRouteNames.taskDetail,
                          pathParameters: {'id': '${task.id}'}),
                  child: Text(l10n.taskDetails)),
          ]),
          if (_sending)
            const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator()),
        ]));
  }
}
