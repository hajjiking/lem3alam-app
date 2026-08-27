import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'task_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../routing/app_router.dart';
import '../domain/task.dart';
import 'nearby_tasks_controller.dart';
import 'task_image_support.dart';

// #region debug-point helpers:nearby-tasks-load-fail
void _dbgEvent({
  required String hypothesisId,
  required String location,
  required String msg,
  required Map<String, dynamic> data,
  String runId = 'pre-fix',
}) {
  try {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: 1400),
      receiveTimeout: const Duration(milliseconds: 1800),
      sendTimeout: const Duration(milliseconds: 1400),
    ));
    const fallbackUrl = 'http://192.168.3.48:7777/event';
    const sessionId = 'nearby-tasks-load-fail';
    unawaited(
      dio
          .post<Object?>(
            fallbackUrl,
            data: jsonEncode({
              'sessionId': sessionId,
              'runId': runId,
              'hypothesisId': hypothesisId,
              'location': location,
              'msg': '[DEBUG] $msg',
              'data': data,
            }),
            options: Options(headers: {'Content-Type': 'application/json'}),
          )
          .then<void>((Response<Object?> _) {})
          .catchError((Object _) {}),
    );
  } catch (_) {}
}
// #endregion

class NearbyTasksScreen extends ConsumerStatefulWidget {
  const NearbyTasksScreen({super.key});

  @override
  ConsumerState<NearbyTasksScreen> createState() => _NearbyTasksScreenState();
}

class _NearbyTasksScreenState extends ConsumerState<NearbyTasksScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    ref.listenManual(nearbyTasksControllerProvider, (previous, next) {
      if (!mounted) return;
      _scheduleRefresh(next.settings.refreshIntervalMinutes);
      if (next.newHighPriorityCount > 0 &&
          previous?.newHighPriorityCount != next.newHighPriorityCount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n
                .newHighPriorityNearbyTasksFound(next.newHighPriorityCount)),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _scheduleRefresh(int minutes) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(minutes: minutes), (_) {
      ref.read(nearbyTasksControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nearbyTasksControllerProvider);
    final controller = ref.read(nearbyTasksControllerProvider.notifier);
    final l10n = context.l10n;

    // #region debug-point A:screen-build-state
    _dbgEvent(
      hypothesisId: 'A',
      location: 'nearby_tasks_screen.dart:95',
      msg: 'Nearby screen built with current state',
      data: {
        'loading': state.loading,
        'hasConsent': state.hasConsent,
        'errorCode': state.errorCode,
        'radiusKm': state.radiusKm,
        'savedOnly': state.savedOnly,
        'pageItemsLength': state.page.items.length,
        'pageCurrent': state.page.currentPage,
        'pageLast': state.page.lastPage,
        'pageTotal': state.page.total,
      },
    );
    // #endregion

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nearbyTasks),
        actions: [
          IconButton(
            onPressed: () => context.goNamed(AppRouteNames.dashboard),
            icon: const Icon(Icons.home_outlined),
            tooltip: l10n.dashboard,
          ),
          const AppThemeModeButton(),
          IconButton(
            onPressed: state.loading ? null : () => controller.refresh(),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshAction,
          ),
        ],
      ),
      body: SafeArea(
        child: !state.hasConsent
            ? _ConsentView(onAllow: controller.grantConsent)
            : Column(
                children: [
                  _ControlsBar(state: state),
                  if (state.hasLowAccuracyWarning)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: AppInlineBanner(
                        message: l10n.locationAccuracyLow,
                        tone: AppBannerTone.info,
                        icon: Icons.gps_not_fixed,
                      ),
                    ),
                  if (state.errorCode != null)
                    Expanded(
                      child: _ErrorView(
                        code: state.errorCode!,
                        onRetry: controller.refresh,
                        onOpenSettings: controller.openSettings,
                        onOpenLocationSettings: controller.openLocationSettings,
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: controller.refresh,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: state.page.items.isEmpty
                              ? 1
                              : state.page.items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (state.page.items.isEmpty) {
                              return AppEmptyState(
                                title: context.l10n.noNearbyTasks,
                                subtitle: context.l10n.noNearbyTasksSubtitle,
                                icon: Icons.assignment_late_outlined,
                              );
                            }
                            final task = state.page.items[index];
                            return _NearbyTaskCard(task: task);
                          },
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _ConsentView extends StatelessWidget {
  const _ConsentView({required this.onAllow});

  final Future<void> Function() onAllow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppSectionCard(
        title: l10n.enableNearbyTaskMatching,
        subtitle: l10n.nearbyTasksConsentSubtitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.nearbyTasksConsentBody),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onAllow,
              icon: const Icon(Icons.my_location),
              label: Text(l10n.allowLocationBasedNearbyTasks),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsBar extends ConsumerWidget {
  const _ControlsBar({required this.state});

  final NearbyTasksState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(nearbyTasksControllerProvider.notifier);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: AppSectionCard(
        title: l10n.feedControls,
        subtitle: state.lastRefreshedAt == null
            ? l10n.radiusAdjustable(
                state.settings.minRadiusKm, state.settings.maxRadiusKm)
            : l10n.lastRefreshedAt(
                '${state.lastRefreshedAt!.hour.toString().padLeft(2, '0')}:${state.lastRefreshedAt!.minute.toString().padLeft(2, '0')}',
              ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.radiusLabel(state.radiusKm),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                FilterChip(
                  selected: state.savedOnly,
                  onSelected: (value) => controller.toggleSavedOnly(value),
                  label: Text(l10n.savedOnly),
                ),
              ],
            ),
            Slider(
              value: state.radiusKm.toDouble(),
              min: state.settings.minRadiusKm.toDouble(),
              max: state.settings.maxRadiusKm.toDouble(),
              divisions:
                  state.settings.maxRadiusKm - state.settings.minRadiusKm,
              label: '${state.radiusKm} km',
              onChanged: (value) => controller.updateRadius(value.round()),
              onChangeEnd: (value) =>
                  controller.updateRadius(value.round(), refreshFeed: true),
            ),
            if (state.loading) const LinearProgressIndicator(minHeight: 2),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.code,
    required this.onRetry,
    required this.onOpenSettings,
    required this.onOpenLocationSettings,
  });

  final String code;
  final Future<void> Function() onRetry;
  final Future<void> Function() onOpenSettings;
  final Future<void> Function() onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (title, message, actionLabel, action) = switch (code) {
      'service_disabled' => (
          l10n.locationDisabled,
          l10n.locationDisabledNearbyTasksMessage,
          l10n.openLocationSettings,
          onOpenLocationSettings,
        ),
      'permission_denied' => (
          l10n.permissionRequired,
          l10n.allowLocationAccessNearbyTasks,
          l10n.retry,
          onRetry,
        ),
      'permission_denied_forever' => (
          l10n.permissionBlocked,
          l10n.enablePermissionInSettings,
          l10n.openSettings,
          onOpenSettings,
        ),
      'forbidden' => (
          l10n.permissionRequired,
          l10n.errForbidden,
          l10n.dashboard,
          () => context.goNamed(AppRouteNames.dashboard),
        ),
      _ => (
          l10n.unableToLoadNearbyTasks,
          l10n.errUnknown,
          l10n.retry,
          onRetry,
        ),
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppSectionCard(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(message),
            const SizedBox(height: 12),
            FilledButton(onPressed: action, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _NearbyTaskCard extends ConsumerWidget {
  const _NearbyTaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final controller = ref.read(nearbyTasksControllerProvider.notifier);
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NearbyTaskImage(task: task),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task.localizedCategoryName(languageCode) ??
                                task.city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _Badge(
                      label: _urgencyLabel(context, task.urgency),
                      background: taskUrgencyColor(context, task.urgency)
                          .withValues(alpha: 0.12),
                      foreground: taskUrgencyColor(context, task.urgency),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Badge(
                      label: task.distanceKm == null
                          ? l10n.distanceUnavailable
                          : '${task.distanceKm!.toStringAsFixed(1)} km',
                      background: scheme.primaryContainer,
                      foreground: scheme.onPrimaryContainer,
                    ),
                    _Badge(
                      label:
                          '${task.budgetMin.toStringAsFixed(0)} - ${task.budgetMax.toStringAsFixed(0)} MAD',
                      background: scheme.secondaryContainer,
                      foreground: scheme.onSecondaryContainer,
                    ),
                    if (task.deadline != null)
                      _Badge(
                        label:
                            task.deadline!.toIso8601String().split('T').first,
                        background: scheme.surfaceContainerHigh,
                        foreground: scheme.onSurface,
                      ),
                    _Badge(
                      label: l10n.clientRatingLabel(
                          task.clientRating?.toStringAsFixed(1) ?? '0.0'),
                      background: scheme.tertiaryContainer,
                      foreground: scheme.onTertiaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  task.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          await controller.accept(task);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      l10n.applicationSubmittedNearbyTask)),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(l10n.accept),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.toggleSave(task),
                        icon: Icon(task.isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_border),
                        label:
                            Text(task.isSaved ? l10n.savedStatus : l10n.save),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () => controller.dismiss(task),
                      icon: const Icon(Icons.close),
                      tooltip: l10n.dismiss,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyTaskImage extends StatelessWidget {
  const _NearbyTaskImage({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedTaskImage(
        source: task.primaryImageSource,
        placeholder: const _NearbyTaskImagePlaceholder(),
      ),
    );
  }
}

class _NearbyTaskImagePlaceholder extends StatelessWidget {
  const _NearbyTaskImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 16 / 9,
      child: TaskImagePlaceholder(),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

String _urgencyLabel(BuildContext context, String urgency) {
  final l10n = context.l10n;
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
