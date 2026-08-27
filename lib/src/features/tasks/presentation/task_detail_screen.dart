import 'package:flutter/material.dart';
import 'task_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';

import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/language_picker.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/task.dart';
import 'task_image_support.dart';
import 'tasks_controller.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final isClient = user?.isClient == true;
    final isTasker = user?.isTasker == true;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taskDetails),
        actions: [
          IconButton(
            onPressed: () => showLanguagePicker(context),
            icon: const Icon(Icons.language),
            tooltip: l10n.languageAction,
          ),
          const AppThemeModeButton(),
          taskAsync.maybeWhen(
            data: (task) => IconButton(
              onPressed: !(isClient && task.clientId == user?.id)
                  ? null
                  : () => context.goNamed(
                        AppRouteNames.taskEdit,
                        pathParameters: {'id': task.id.toString()},
                      ),
              icon: const Icon(Icons.edit),
              tooltip: l10n.editTask,
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const _TaskDetailSkeleton(),
        error: (e, _) => AppErrorState(
          title: l10n.unableToLoad,
          subtitle: _errorMessage(context, e),
          debugDetails: e.toString(),
          retryLabel: l10n.retry,
          onRetry: () => ref.invalidate(taskDetailProvider(taskId)),
        ),
        data: (task) => SafeArea(
          child: AppResponsiveCenter(
            maxWidth: 760,
            padding: EdgeInsets.zero,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'task-title-${task.id}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            task.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          AppPill(
                            icon: Icons.place_outlined,
                            label: task.city,
                            background: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.6),
                            foreground: colorScheme.onSurfaceVariant,
                          ),
                          AppPill(
                            icon: Icons.payments_outlined,
                            label:
                                '${task.budgetMin.toStringAsFixed(0)} - ${task.budgetMax.toStringAsFixed(0)}',
                            background: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.6),
                            foreground: colorScheme.onSurfaceVariant,
                          ),
                          AppPill(
                            icon: Icons.flag_outlined,
                            label: _urgencyLabel(l10n, task.urgency),
                            background: taskUrgencyColor(context, task.urgency)
                                .withValues(alpha: 0.12),
                            foreground: taskUrgencyColor(context, task.urgency),
                          ),
                          AppPill(
                            icon: Icons.info_outline,
                            label: _statusLabel(l10n, task.status),
                            background: taskStatusColor(context, task.status)
                                .withValues(alpha: 0.12),
                            foreground: taskStatusColor(context, task.status),
                          ),
                          if ((task.localizedCategoryName(languageCode) ?? '')
                              .isNotEmpty)
                            AppPill(
                              icon: Icons.category_outlined,
                              label: task.localizedCategoryName(languageCode)!,
                              background: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.6),
                              foreground: colorScheme.onSurfaceVariant,
                            ),
                          if ((task.clientName ?? '').isNotEmpty)
                            AppPill(
                              icon: Icons.person_outline,
                              label: task.clientName!,
                              background: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.6),
                              foreground: colorScheme.onSurfaceVariant,
                            ),
                          if (task.deadline != null)
                            AppPill(
                              icon: Icons.event_outlined,
                              label: task.deadline!
                                  .toIso8601String()
                                  .split('T')
                                  .first,
                              background: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.6),
                              foreground: colorScheme.onSurfaceVariant,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (task.latitude != null && task.longitude != null)
                  const SizedBox(height: 12),
                if (task.latitude != null && task.longitude != null)
                  AppSectionCard(
                    title: l10n.location,
                    child: SizedBox(
                      height: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter:
                                LatLng(task.latitude!, task.longitude!),
                            initialZoom: 15,
                            interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.all),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'lem3alam_mobile',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point:
                                      LatLng(task.latitude!, task.longitude!),
                                  width: 46,
                                  height: 46,
                                  child: Icon(
                                    Icons.location_on,
                                    size: 46,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (task.images.isNotEmpty) const SizedBox(height: 12),
                if (task.images.isNotEmpty)
                  AppSectionCard(
                    title: l10n.photos,
                    child: SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: task.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final url = resolveTaskImageUrl(task.images[index]);
                          if (url == null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: const SizedBox(
                                width: 110,
                                height: 110,
                                child: TaskImagePlaceholder(),
                              ),
                            );
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _previewNetworkImage(context, url),
                                child: SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: CachedTaskImage(
                                    source: url,
                                    placeholder: const SizedBox(
                                      width: 110,
                                      height: 110,
                                      child: TaskImagePlaceholder(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                AppSectionCard(
                  title: l10n.description,
                  child: Text(task.description),
                ),
                if (task.assignedTaskerId != null) const SizedBox(height: 12),
                if (task.assignedTaskerId != null)
                  AppSectionCard(
                    title: l10n.tasker,
                    trailing: TextButton(
                      onPressed: () => context.goNamed(
                        AppRouteNames.taskerProfile,
                        pathParameters: {
                          'id': task.assignedTaskerId.toString()
                        },
                      ),
                      child: Text(l10n.viewProfile),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            (task.assignedTaskerName ?? '').trim().isEmpty
                                ? '—'
                                : task.assignedTaskerName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                if (isTasker && task.status == 'open')
                  FilledButton.icon(
                    onPressed: () =>
                        _showApplySheet(context, ref, taskId: task.id),
                    icon: const Icon(Icons.send_outlined),
                    label: Text(l10n.apply),
                  ),
                if (isTasker && task.status == 'open')
                  const SizedBox(height: 12),
                if (isClient && task.clientId == user?.id)
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.deleteTask),
                          content: Text(l10n.confirmDeleteTask),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel)),
                            FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(l10n.delete)),
                          ],
                        ),
                      );
                      if (ok != true) return;
                      await ref
                          .read(taskMutationControllerProvider)
                          .delete(task.id);
                      ref.invalidate(tasksListControllerProvider);
                      if (context.mounted) context.goNamed(AppRouteNames.tasks);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.deleteTask),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showApplySheet(
  BuildContext context,
  WidgetRef ref, {
  required int taskId,
}) async {
  final l10n = context.l10n;
  final formKey = GlobalKey<FormState>();
  final proposalController = TextEditingController();
  final budgetController = TextEditingController();
  final durationController = TextEditingController();
  var submitting = false;

  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.applyToTask,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: proposalController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.proposal,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: budgetController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.proposedBudget,
                    prefixIcon: const Icon(Icons.payments_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.requiredField;
                    }
                    final parsed = double.tryParse(v.replaceAll(',', '.'));
                    if (parsed == null || parsed < 0) return l10n.requiredField;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: durationController,
                  decoration: InputDecoration(
                    labelText: l10n.estimatedDuration,
                    prefixIcon: const Icon(Icons.schedule_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          final budget = double.parse(budgetController.text
                              .trim()
                              .replaceAll(',', '.'));
                          final payload = TaskApplicationPayload(
                            proposal: proposalController.text.trim(),
                            proposedBudget: budget,
                            estimatedDuration: durationController.text.trim(),
                          );

                          setState(() => submitting = true);
                          try {
                            await ref
                                .read(taskMutationControllerProvider)
                                .apply(taskId: taskId, payload: payload);
                            ref.invalidate(taskDetailProvider(taskId));
                            ref.invalidate(tasksListControllerProvider);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(l10n.applicationSubmitted)),
                              );
                            }
                          } on ApiException catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text(localizeApiException(context, e))),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setState(() => submitting = false);
                            }
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.submitApplication),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } finally {
    proposalController.dispose();
    budgetController.dispose();
    durationController.dispose();
  }
}

Future<void> _previewNetworkImage(BuildContext context, String url) async {
  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              child: CachedTaskImage(
                source: url,
                fit: BoxFit.contain,
                placeholder: const TaskImagePlaceholder(),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          ),
        ],
      ),
    ),
  );
}

String _errorMessage(BuildContext context, Object error) {
  if (error is ApiException) {
    return localizeApiException(context, error);
  }
  return context.l10n.errUnknown;
}

class _TaskDetailSkeleton extends StatelessWidget {
  const _TaskDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppResponsiveCenter(
        maxWidth: 760,
        padding: EdgeInsets.zero,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AppSkeletonBox(height: 22, width: 260),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        AppSkeletonBox(height: 24, width: 120, radius: 999),
                        SizedBox(width: 8),
                        AppSkeletonBox(height: 24, width: 140, radius: 999),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        AppSkeletonBox(height: 24, width: 110, radius: 999),
                        SizedBox(width: 8),
                        AppSkeletonBox(height: 24, width: 96, radius: 999),
                        SizedBox(width: 8),
                        AppSkeletonBox(height: 24, width: 120, radius: 999),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AppSkeletonBox(height: 18, width: 120),
                    SizedBox(height: 10),
                    AppSkeletonBox(height: 14, width: double.infinity),
                    SizedBox(height: 8),
                    AppSkeletonBox(height: 14, width: double.infinity),
                    SizedBox(height: 8),
                    AppSkeletonBox(height: 14, width: 260),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'open':
      return l10n.statusOpen;
    case 'assigned':
      return l10n.statusAssigned;
    case 'in_progress':
      return l10n.statusInProgress;
    case 'completed':
      return l10n.statusCompleted;
    case 'cancelled':
      return l10n.statusCancelled;
    default:
      return status;
  }
}

String _urgencyLabel(AppLocalizations l10n, String urgency) {
  switch (urgency) {
    case 'urgent':
      return l10n.urgencyUrgent;
    case 'high':
      return l10n.urgencyHigh;
    case 'medium':
      return l10n.urgencyMedium;
    case 'low':
      return l10n.urgencyLow;
    default:
      return urgency;
  }
}
