import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../application/dashboard_controller.dart';
import '../domain/dashboard_models.dart';
import 'widgets/dashboard_widgets.dart';
import 'dashboard_actions.dart';
import 'widgets/tasker_analytics_section.dart';
import '../../tasks/data/tasker_assignments_repository.dart';
import '../../tasks/presentation/tasker_assignments_panel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<Lem3alamThemeTokens>()!;
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final dashboard = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);
    final user = auth.user;
    final rawName = user?.name.trim() ?? '';
    final displayName =
        rawName.isEmpty ? l10n.tasker : rawName.split(RegExp(r'\s+')).first;
    final numberFormat = NumberFormat.decimalPattern(l10n.localeName);
    final ratingFormat = NumberFormat('0.0', l10n.localeName);
    final stats = dashboard.snapshot.stats;

    final statItems = <DashboardStatViewData>[
      DashboardStatViewData(
        label: l10n.dashboardActiveTasks,
        value: numberFormat.format(stats.activeTasks),
        icon: Icons.business_center_outlined,
        accent: scheme.primary,
      ),
      DashboardStatViewData(
        label: l10n.dashboardCompleted,
        value: numberFormat.format(stats.completedTasks),
        icon: Icons.assignment_turned_in_outlined,
        accent: tokens.success,
      ),
      DashboardStatViewData(
        label: l10n.dashboardTotalEarnings,
        value: numberFormat.format(stats.totalEarnings),
        secondaryLabel: l10n.dashboardCurrencyMad,
        icon: Icons.account_balance_wallet_outlined,
        accent: tokens.accentPurple,
      ),
      DashboardStatViewData(
        label: l10n.dashboardRating,
        value: ratingFormat.format(stats.rating),
        icon: Icons.star_outline_rounded,
        labelIcon: Icons.star_rounded,
        accent: tokens.warning,
      ),
    ];
    final tasks = dashboard.visibleTasks
        .map(
          (task) => DashboardTaskViewData(
            title: task.title,
            location: task.city,
            category: task.category,
            timeAgo: task.hoursAgo >= 24
                ? l10n.dashboardDaysAgo(task.hoursAgo ~/ 24)
                : l10n.dashboardHoursAgo(task.hoursAgo),
            status: task.status,
            statusLabel: _taskStatus(l10n, task.status),
            price: l10n.dashboardPrice(numberFormat.format(task.price)),
            icon: _taskIcon(task.category),
            accent: scheme.primary,
          ),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(taskerAssignmentsProvider);
            await controller.load();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            key: const PageStorageKey('tasker-dashboard-scroll'),
            padding: EdgeInsets.zero,
            children: [
              DashboardHeader(
                appName: l10n.appName,
                greeting: l10n.dashboardGreeting(displayName),
                subtitle: l10n.dashboardReadySubtitle,
                availabilityLabel: l10n.dashboardOffline,
                isOnline: false,
                showAvailability: false,
                menuLabel: l10n.dashboardMenu,
                notificationsLabel: l10n.dashboardNotifications,
                profileLabel: l10n.dashboardProfile,
                avatarAsset: null,
                onMenuTap: () => showDashboardMenu(context, ref),
                onNotificationsTap: () => showDashboardFeatureNotice(
                  context,
                  l10n.dashboardNotifications,
                ),
                onProfileTap: () => openDashboardProfile(
                    context, user?.id, user?.isTasker == true),
                onAvailabilityTap: () {},
              ),
              if (dashboard.isLoading)
                const LinearProgressIndicator(minHeight: 2),
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
                            const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (dashboard.isLoading)
                              const AppSkeletonBox(height: 240)
                            else if (dashboard.error != null)
                              AppErrorState(
                                  title: l10n.taskerDashboardLoadError,
                                  subtitle: l10n.taskerDashboardRetryHint,
                                  onRetry: controller.load)
                            else if (dashboard.hasLoaded) ...[
                              DashboardStatsRow(items: statItems),
                              const SizedBox(height: 28),
                              const TaskerAssignmentsPanel(),
                              const SizedBox(height: 28),
                              TaskerAnalyticsSection(
                                  snapshot: dashboard.snapshot,
                                  range: dashboard.performanceRange,
                                  onRangeSelected:
                                      controller.selectPerformanceRange),
                              const SizedBox(height: 28),
                              DashboardSectionHeader(
                                title: l10n.dashboardRecentTasks,
                                actionLabel: l10n.dashboardViewAll,
                                onActionTap: () =>
                                    context.goNamed(AppRouteNames.tasks),
                              ),
                              const SizedBox(height: 10),
                              DashboardFilterBar(
                                selected: dashboard.selectedFilter,
                                pendingLabel: l10n
                                    .dashboardPendingCount(stats.pendingTasks),
                                acceptedLabel: l10n.dashboardAcceptedCount(
                                    stats.acceptedTasks),
                                completedLabel: l10n.dashboardCompletedFilter,
                                onSelected: controller.selectFilter,
                              ),
                              const SizedBox(height: 14),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                child: tasks.isEmpty
                                    ? DashboardEmptyState(
                                        key: ValueKey(dashboard.selectedFilter),
                                        label: l10n.dashboardNoFilteredTasks,
                                      )
                                    : Column(
                                        key: ValueKey(dashboard.selectedFilter),
                                        children: [
                                          for (var index = 0;
                                              index < tasks.length;
                                              index++) ...[
                                            DashboardTaskCard(
                                              data: tasks[index],
                                              onTap: () => context.goNamed(
                                                  AppRouteNames.taskDetail,
                                                  pathParameters: {
                                                    'id': dashboard
                                                        .visibleTasks[index].id
                                                        .toString()
                                                  }),
                                            ),
                                            if (index != tasks.length - 1)
                                              const SizedBox(height: 12),
                                          ],
                                        ],
                                      ),
                              ),
                              const SizedBox(height: 24),
                              DashboardPromoBanner(
                                title: l10n.dashboardGrowBusiness,
                                subtitle: l10n.dashboardGrowBusinessSubtitle,
                                actionLabel: l10n.dashboardBoostProfile,
                                onTap: () => openDashboardProfile(
                                  context,
                                  user?.id,
                                  user?.isTasker == true,
                                ),
                              ),
                              const SizedBox(height: 28),
                              const SizedBox(height: 24),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

String _taskStatus(AppLocalizations l10n, DashboardTaskStatus status) {
  return switch (status) {
    DashboardTaskStatus.fresh => l10n.dashboardStatusNew,
    DashboardTaskStatus.pending => l10n.dashboardStatusPending,
    DashboardTaskStatus.accepted => l10n.statusAssigned,
    DashboardTaskStatus.completed => l10n.statusCompleted,
  };
}

IconData _taskIcon(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('plumb') || normalized.contains('سباك')) {
    return Icons.plumbing_rounded;
  }
  if (normalized.contains('electric') || normalized.contains('كهرب')) {
    return Icons.lightbulb_outline_rounded;
  }
  return Icons.build_outlined;
}
