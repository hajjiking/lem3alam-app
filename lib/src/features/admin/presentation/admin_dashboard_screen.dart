import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/widgets/dashboard_header.dart';
import '../application/admin_dashboard_view_controller.dart';
import '../domain/admin_dashboard_models.dart';
import 'admin_dashboard_controller.dart';
import 'widgets/admin_dashboard_colors.dart';
import 'widgets/metric_card.dart';
import 'widgets/metrics_grid.dart';
import 'widgets/recent_tasks_card.dart';
import 'widgets/tasks_overview_chart.dart';
import 'widgets/tasks_status_donut.dart';
import 'widgets/top_categories_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({
    super.key,
    required this.onMenuTap,
    required this.onNotificationsTap,
    required this.onProfileTap,
    required this.onTasksTap,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;
  final VoidCallback onTasksTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final viewState = ref.watch(adminDashboardViewControllerProvider);
    final viewController =
        ref.read(adminDashboardViewControllerProvider.notifier);
    final summaryAsync = ref.watch(adminDashboardProvider);
    final liveSummary = summaryAsync.asData?.value;
    final snapshot = liveSummary == null
        ? viewState.snapshot
        : viewState.snapshot.withLiveTotals(
            usersCount: liveSummary.usersCount,
            tasksCount: liveSummary.tasksCount,
          );
    final rawName = auth.user?.name.trim() ?? '';
    final displayName = rawName.isEmpty
        ? l10n.adminDefaultName
        : rawName.split(RegExp(r'\s+')).first;
    final numberFormat = NumberFormat.decimalPattern(l10n.localeName);
    final decimalFormat = NumberFormat('0.0', l10n.localeName);
    final metrics = snapshot.metrics
        .map(
          (metric) => AdminMetricCardData(
            label: _metricLabel(l10n, metric.kind),
            value: numberFormat.format(metric.value),
            deltaValue: '${decimalFormat.format(metric.deltaPercent.abs())}%',
            deltaCaption: l10n.adminVsLast7Days,
            icon: _metricIcon(metric.kind),
            accent: adminDashboardColor(context, metric.colorKey),
            isPositive: metric.isPositive,
          ),
        )
        .toList(growable: false);
    final totalTasks = snapshot.valueFor(AdminMetricKind.totalTasks);
    final statusItems = snapshot.statusSlices
        .map(
          (slice) => AdminStatusLegendData(
            label: _statusLabel(l10n, slice.status),
            value: numberFormat.format(slice.value),
            percentLabel:
                '${decimalFormat.format(totalTasks == 0 ? 0 : slice.value * 100 / totalTasks)}%',
            color: adminDashboardColor(context, slice.colorKey),
            chartValue: slice.value.toDouble(),
          ),
        )
        .toList(growable: false);
    final recentTasks = snapshot.recentTasks
        .map(
          (task) => AdminRecentTaskViewData(
            title: _recentTaskTitle(l10n, task.kind),
            customerLabel: l10n.adminTaskBy(task.customerName),
            statusLabel: _statusLabel(l10n, task.status),
            timeLabel: task.minutesAgo < 60
                ? l10n.adminMinutesAgo(task.minutesAgo)
                : l10n.dashboardHoursAgo(task.minutesAgo ~/ 60),
            thumbnailUrl: task.thumbnailUrl,
            statusColor: _statusColor(context, task.status),
            fallbackIcon: _recentTaskIcon(task.kind),
          ),
        )
        .toList(growable: false);
    final categories = snapshot.categories
        .map(
          (category) => AdminCategoryViewData(
            label: _categoryLabel(l10n, category.kind),
            count: numberFormat.format(category.count),
            percent: '${decimalFormat.format(category.percent)}%',
            icon: _categoryIcon(category.kind),
            accent: adminDashboardColor(context, category.colorKey),
          ),
        )
        .toList(growable: false);
    final dayLabels = viewState.range == AdminDashboardRange.week
        ? [
            l10n.mon,
            l10n.tue,
            l10n.wed,
            l10n.thu,
            l10n.fri,
            l10n.sat,
            l10n.sun,
          ]
        : [
            for (var index = 1;
                index <= viewState.visibleSeries.length;
                index++)
              l10n.adminWeekShort(index),
          ];

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(adminActionControllerProvider.notifier).refreshAll(),
      child: ListView(
        key: const PageStorageKey('admin-dashboard-scroll'),
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          DashboardHeader(
            appName: l10n.appName,
            greeting: l10n.adminGreeting(displayName),
            subtitle: l10n.adminDashboardSubtitle,
            availabilityLabel: viewState.isOnline
                ? l10n.dashboardOnline
                : l10n.dashboardOffline,
            isOnline: viewState.isOnline,
            menuLabel: l10n.dashboardMenu,
            notificationsLabel: l10n.dashboardNotifications,
            profileLabel: l10n.dashboardProfile,
            notificationCount: 3,
            avatarAsset: null,
            avatarFallback: Icons.admin_panel_settings_rounded,
            onMenuTap: onMenuTap,
            onNotificationsTap: onNotificationsTap,
            onProfileTap: onProfileTap,
            onAvailabilityTap: viewController.toggleAvailability,
          ),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Align(
                alignment: AlignmentDirectional.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (summaryAsync.isLoading) ...[
                          const LinearProgressIndicator(),
                          const SizedBox(height: 12),
                        ],
                        if (summaryAsync.hasError) ...[
                          AppInlineBanner(
                            message: l10n.adminAnalyticsFallback,
                            tone: AppBannerTone.info,
                            icon: Icons.cloud_off_outlined,
                          ),
                          const SizedBox(height: 12),
                        ],
                        AdminMetricsGrid(
                          items: metrics,
                          detailsLabel: l10n.dashboardViewDetails,
                          onSelected: (index) => _showFeatureNotice(
                            context,
                            metrics[index].label,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _ResponsivePair(
                          firstFlex: 2,
                          first: TasksOverviewChart(
                            title: l10n.adminTasksOverview,
                            rangeLabel:
                                viewState.range == AdminDashboardRange.week
                                    ? l10n.dashboardThisWeek
                                    : l10n.dashboardThisMonth,
                            points: viewState.visibleSeries,
                            dayLabels: dayLabels,
                            legendItems: [
                              AdminChartLegendItem(
                                label: l10n.adminPosted,
                                color: scheme.primary,
                              ),
                              AdminChartLegendItem(
                                label: l10n.adminInProgress,
                                color: adminDashboardColor(
                                  context,
                                  AdminColorKey.warning,
                                ),
                              ),
                              AdminChartLegendItem(
                                label: l10n.dashboardCompleted,
                                color: scheme.tertiary,
                              ),
                            ],
                            onRangeTap: () => _showRangePicker(
                              context,
                              ref,
                              viewState.range,
                            ),
                          ),
                          second: TasksStatusDonut(
                            title: l10n.adminTasksByStatus,
                            totalLabel: l10n.adminTotal,
                            totalValue: numberFormat.format(totalTasks),
                            items: statusItems,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _ResponsivePair(
                          first: AdminRecentTasksCard(
                            title: l10n.dashboardRecentTasks,
                            viewAllLabel: l10n.dashboardViewAll,
                            viewAllTasksLabel: l10n.adminViewAllTasks,
                            items: recentTasks,
                            onViewAll: onTasksTap,
                            onTaskTap: (_) => onTasksTap(),
                          ),
                          second: AdminTopCategoriesCard(
                            title: l10n.adminTopCategories,
                            viewAllLabel: l10n.dashboardViewAll,
                            items: categories,
                            onViewAll: () => _showFeatureNotice(
                              context,
                              l10n.adminTopCategories,
                            ),
                            onCategoryTap: (index) => _showFeatureNotice(
                              context,
                              categories[index].label,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureNotice(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.dashboardFeatureUnavailable(feature)),
        ),
      );
  }

  Future<void> _showRangePicker(
    BuildContext context,
    WidgetRef ref,
    AdminDashboardRange selected,
  ) async {
    final l10n = context.l10n;
    final value = await showModalBottomSheet<AdminDashboardRange>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AdminDashboardRange>(
                value: AdminDashboardRange.week,
                groupValue: selected,
                title: Text(l10n.dashboardThisWeek),
                onChanged: (value) => Navigator.of(context).pop(value),
              ),
              RadioListTile<AdminDashboardRange>(
                value: AdminDashboardRange.month,
                groupValue: selected,
                title: Text(l10n.dashboardThisMonth),
                onChanged: (value) => Navigator.of(context).pop(value),
              ),
            ],
          ),
        ),
      ),
    );
    if (value != null) {
      ref
          .read(adminDashboardViewControllerProvider.notifier)
          .selectRange(value);
    }
  }
}

class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({
    required this.first,
    required this.second,
    this.firstFlex = 1,
  });

  final Widget first;
  final Widget second;
  final int firstFlex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 820) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, const SizedBox(height: 14), second],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: firstFlex, child: first),
            const SizedBox(width: 16),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

String _metricLabel(AppLocalizations l10n, AdminMetricKind kind) {
  return switch (kind) {
    AdminMetricKind.totalUsers => l10n.adminTotalUsers,
    AdminMetricKind.totalTasks => l10n.adminTotalTasks,
    AdminMetricKind.completedTasks => l10n.adminCompletedTasks,
    AdminMetricKind.activeTaskers => l10n.adminActiveTaskers,
    AdminMetricKind.pendingTasks => l10n.adminPendingTasks,
    AdminMetricKind.pendingReviews => l10n.adminPendingReviews,
  };
}

IconData _metricIcon(AdminMetricKind kind) {
  return switch (kind) {
    AdminMetricKind.totalUsers => Icons.people_alt_rounded,
    AdminMetricKind.totalTasks => Icons.assignment_turned_in_rounded,
    AdminMetricKind.completedTasks => Icons.check_circle_outline_rounded,
    AdminMetricKind.activeTaskers => Icons.person_rounded,
    AdminMetricKind.pendingTasks => Icons.schedule_rounded,
    AdminMetricKind.pendingReviews => Icons.chat_bubble_outline_rounded,
  };
}

String _statusLabel(AppLocalizations l10n, AdminTaskStatus status) {
  return switch (status) {
    AdminTaskStatus.inProgress => l10n.adminInProgress,
    AdminTaskStatus.completed => l10n.dashboardCompleted,
    AdminTaskStatus.pending => l10n.dashboardStatusPending,
    AdminTaskStatus.cancelled => l10n.adminCancelled,
  };
}

Color _statusColor(BuildContext context, AdminTaskStatus status) {
  return switch (status) {
    AdminTaskStatus.inProgress => Theme.of(context).colorScheme.primary,
    AdminTaskStatus.completed => Theme.of(context).colorScheme.tertiary,
    AdminTaskStatus.pending =>
      adminDashboardColor(context, AdminColorKey.warning),
    AdminTaskStatus.cancelled => Theme.of(context).colorScheme.error,
  };
}

String _recentTaskTitle(
  AppLocalizations l10n,
  AdminRecentTaskKind kind,
) {
  return switch (kind) {
    AdminRecentTaskKind.washingMachine => l10n.dashboardRepairWashingMachine,
    AdminRecentTaskKind.kitchenFaucet => l10n.dashboardFixKitchenFaucet,
    AdminRecentTaskKind.ledLights => l10n.dashboardInstallLedLights,
  };
}

IconData _recentTaskIcon(AdminRecentTaskKind kind) {
  return switch (kind) {
    AdminRecentTaskKind.washingMachine => Icons.local_laundry_service_outlined,
    AdminRecentTaskKind.kitchenFaucet => Icons.plumbing_rounded,
    AdminRecentTaskKind.ledLights => Icons.lightbulb_outline_rounded,
  };
}

String _categoryLabel(AppLocalizations l10n, AdminCategoryKind kind) {
  return switch (kind) {
    AdminCategoryKind.homeRepairs => l10n.adminHomeRepairs,
    AdminCategoryKind.plumbing => l10n.dashboardPlumbing,
    AdminCategoryKind.electrical => l10n.dashboardElectrical,
    AdminCategoryKind.cleaning => l10n.adminCleaning,
    AdminCategoryKind.painting => l10n.adminPainting,
  };
}

IconData _categoryIcon(AdminCategoryKind kind) {
  return switch (kind) {
    AdminCategoryKind.homeRepairs => Icons.handyman_rounded,
    AdminCategoryKind.plumbing => Icons.plumbing_rounded,
    AdminCategoryKind.electrical => Icons.bolt_rounded,
    AdminCategoryKind.cleaning => Icons.cleaning_services_rounded,
    AdminCategoryKind.painting => Icons.format_paint_rounded,
  };
}
