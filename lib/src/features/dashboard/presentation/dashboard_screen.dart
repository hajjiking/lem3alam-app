import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/language_picker.dart';
import '../../../core/ui/app_theme.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../application/dashboard_controller.dart';
import '../domain/dashboard_models.dart';
import 'widgets/dashboard_widgets.dart';

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
    final performance = dashboard.snapshot.performance;
    final hasDashboardData = dashboard.snapshot.tasks.isNotEmpty ||
        stats.activeTasks != 0 ||
        stats.completedTasks != 0 ||
        stats.totalEarnings != 0 ||
        stats.rating != 0 ||
        performance.points.isNotEmpty;

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
            title: _taskTitle(l10n, task.kind),
            location: _taskLocation(l10n, task.city),
            category: _taskCategory(l10n, task.category),
            timeAgo: task.hoursAgo >= 24
                ? l10n.dashboardDaysAgo(task.hoursAgo ~/ 24)
                : l10n.dashboardHoursAgo(task.hoursAgo),
            status: task.status,
            statusLabel: _taskStatus(l10n, task.status),
            price: l10n.dashboardPrice(numberFormat.format(task.price)),
            icon: _taskIcon(task.kind),
            accent: scheme.primary,
          ),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: ListView(
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
            onMenuTap: () => _showDashboardMenu(context, ref),
            onNotificationsTap: () => _showFeatureNotice(
              context,
              l10n.dashboardNotifications,
            ),
            onProfileTap: () =>
                _openProfile(context, user?.id, user?.isTasker == true),
            onAvailabilityTap: () {},
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
                        const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!hasDashboardData) ...[
                          DashboardEmptyState(
                            label: l10n.dashboardLiveDataUnavailable,
                          ),
                          const SizedBox(height: 24),
                          DashboardPromoBanner(
                            title: l10n.dashboardGrowBusiness,
                            subtitle: l10n.dashboardGrowBusinessSubtitle,
                            actionLabel: l10n.dashboardBoostProfile,
                            onTap: () => _openProfile(
                              context,
                              user?.id,
                              user?.isTasker == true,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                          DashboardStatsRow(items: statItems),
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
                            pendingLabel:
                                l10n.dashboardPendingCount(stats.pendingTasks),
                            acceptedLabel: l10n
                                .dashboardAcceptedCount(stats.acceptedTasks),
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
                                          onTap: () => context
                                              .goNamed(AppRouteNames.tasks),
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
                            onTap: () => _openProfile(
                              context,
                              user?.id,
                              user?.isTasker == true,
                            ),
                          ),
                          const SizedBox(height: 28),
                          DashboardPerformanceSection(
                            title: l10n.dashboardPerformance,
                            earningsLabel: l10n.dashboardEarnings,
                            earningsValue: l10n.dashboardPrice(
                              numberFormat.format(performance.earnings),
                            ),
                            tasksCompletedLabel: l10n.dashboardTasksCompleted,
                            tasksCompletedValue: numberFormat.format(
                              performance.tasksCompleted,
                            ),
                            earningsChangeLabel: l10n.dashboardChangeVsLastWeek(
                              performance.earningsChangePercent,
                            ),
                            tasksChangeLabel: l10n.dashboardChangeVsLastWeek(
                              performance.tasksChangePercent,
                            ),
                            selectedRange: dashboard.performanceRange,
                            weekLabel: l10n.dashboardThisWeek,
                            monthLabel: l10n.dashboardThisMonth,
                            dayLabels: [
                              l10n.mon,
                              l10n.tue,
                              l10n.wed,
                              l10n.thu,
                              l10n.fri,
                              l10n.sat,
                              l10n.sun,
                            ],
                            points: performance.points,
                            onRangeSelected: controller.selectPerformanceRange,
                          ),
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
      ),
    );
  }

  void _showFeatureNotice(BuildContext context, String feature) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10n.dashboardFeatureUnavailable(feature))),
      );
  }

  void _openProfile(BuildContext context, int? userId, bool isTasker) {
    if (isTasker && userId != null) {
      context.goNamed(
        AppRouteNames.taskerProfile,
        pathParameters: {'id': userId.toString()},
      );
      return;
    }
    _showFeatureNotice(context, context.l10n.dashboardProfile);
  }

  Future<void> _showDashboardMenu(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final themeModeNotifier = ref.read(themeModeControllerProvider.notifier);
    final isDark = themeModeNotifier.effectiveBrightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(l10n.languageAction),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showLanguagePicker(context);
              },
            ),
            ListTile(
              leading: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              title: Text(
                isDark ? l10n.dashboardLightMode : l10n.dashboardDarkMode,
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref.read(themeModeControllerProvider.notifier).toggle();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: Text(l10n.logout),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.goNamed(AppRouteNames.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}

String _taskTitle(AppLocalizations l10n, DashboardTaskKind kind) {
  return switch (kind) {
    DashboardTaskKind.repairWashingMachine =>
      l10n.dashboardRepairWashingMachine,
    DashboardTaskKind.fixKitchenFaucet => l10n.dashboardFixKitchenFaucet,
    DashboardTaskKind.installLedLights => l10n.dashboardInstallLedLights,
  };
}

String _taskLocation(AppLocalizations l10n, DashboardCity city) {
  return switch (city) {
    DashboardCity.rabat => l10n.dashboardRabatMorocco,
    DashboardCity.casablanca => l10n.dashboardCasablancaMorocco,
    DashboardCity.marrakech => l10n.dashboardMarrakechMorocco,
  };
}

String _taskCategory(AppLocalizations l10n, DashboardTaskCategory category) {
  return switch (category) {
    DashboardTaskCategory.homeAppliance => l10n.dashboardHomeAppliance,
    DashboardTaskCategory.plumbing => l10n.dashboardPlumbing,
    DashboardTaskCategory.electrical => l10n.dashboardElectrical,
  };
}

String _taskStatus(AppLocalizations l10n, DashboardTaskStatus status) {
  return switch (status) {
    DashboardTaskStatus.fresh => l10n.dashboardStatusNew,
    DashboardTaskStatus.pending => l10n.dashboardStatusPending,
    DashboardTaskStatus.accepted => l10n.statusAssigned,
    DashboardTaskStatus.completed => l10n.statusCompleted,
  };
}

IconData _taskIcon(DashboardTaskKind kind) {
  return switch (kind) {
    DashboardTaskKind.repairWashingMachine => Icons.build_outlined,
    DashboardTaskKind.fixKitchenFaucet => Icons.plumbing_rounded,
    DashboardTaskKind.installLedLights => Icons.lightbulb_outline_rounded,
  };
}
