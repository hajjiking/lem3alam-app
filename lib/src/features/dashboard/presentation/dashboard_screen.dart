import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/language_picker.dart';
import '../../../core/ui/app_theme.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import 'widgets/dashboard_components.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardTaskFilter _filter = DashboardTaskFilter.pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<Lem3alamThemeTokens>()!;
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final rawName = user?.name.trim() ?? '';
    final displayName =
        rawName.isEmpty ? l10n.tasker : rawName.split(RegExp(r'\s+')).first;
    final numberFormat = NumberFormat.decimalPattern(l10n.localeName);
    final percentFormat = NumberFormat.percentPattern(l10n.localeName);

    final stats = <DashboardStatData>[
      DashboardStatData(
        label: l10n.dashboardActiveTasks,
        value: numberFormat.format(3),
        icon: Icons.business_center_outlined,
        accent: scheme.primary,
      ),
      DashboardStatData(
        label: l10n.dashboardCompleted,
        value: numberFormat.format(24),
        icon: Icons.star_outline_rounded,
        accent: scheme.tertiary,
      ),
      DashboardStatData(
        label: l10n.dashboardSuccessRate,
        value: percentFormat.format(0.95),
        icon: Icons.bar_chart_rounded,
        accent: tokens.warning,
      ),
    ];

    final tasks = <DashboardTaskData>[
      DashboardTaskData(
        title: l10n.dashboardRepairWashingMachine,
        location: l10n.dashboardRabatMorocco,
        category: l10n.dashboardHomeAppliance,
        timeAgo: l10n.dashboardHoursAgo(2),
        status: DashboardTaskStatus.fresh,
        statusLabel: l10n.dashboardStatusNew,
        price: l10n.dashboardPrice(numberFormat.format(120)),
        icon: Icons.build_outlined,
        accent: scheme.primary,
      ),
      DashboardTaskData(
        title: l10n.dashboardFixKitchenFaucet,
        location: l10n.dashboardCasablancaMorocco,
        category: l10n.dashboardPlumbing,
        timeAgo: l10n.dashboardHoursAgo(5),
        status: DashboardTaskStatus.fresh,
        statusLabel: l10n.dashboardStatusNew,
        price: l10n.dashboardPrice(numberFormat.format(100)),
        icon: Icons.plumbing_rounded,
        accent: scheme.tertiary,
      ),
      DashboardTaskData(
        title: l10n.dashboardInstallLedLights,
        location: l10n.dashboardMarrakechMorocco,
        category: l10n.dashboardElectrical,
        timeAgo: l10n.dashboardDaysAgo(1),
        status: DashboardTaskStatus.pending,
        statusLabel: l10n.dashboardStatusPending,
        price: l10n.dashboardPrice(numberFormat.format(150)),
        icon: Icons.lightbulb_outline_rounded,
        accent: tokens.warning,
      ),
    ];

    return Scaffold(
      backgroundColor: scheme.surface,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          DashboardHeader(
            appName: l10n.appName,
            greeting: l10n.dashboardGreeting(displayName),
            subtitle: l10n.dashboardReadySubtitle,
            onlineLabel: l10n.dashboardOnline,
            menuLabel: l10n.dashboardMenu,
            notificationsLabel: l10n.dashboardNotifications,
            profileLabel: l10n.dashboardProfile,
            onMenuTap: () => _showDashboardMenu(context),
            onNotificationsTap: () => _showFeatureNotice(
              context,
              l10n.dashboardNotifications,
            ),
            onProfileTap: () {
              if (user?.isTasker == true) {
                context.goNamed(
                  AppRouteNames.taskerProfile,
                  pathParameters: {'id': user!.id.toString()},
                );
              } else {
                _showFeatureNotice(context, l10n.dashboardProfile);
              }
            },
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
                        const EdgeInsetsDirectional.fromSTEB(20, 30, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardStats(
                          items: stats,
                          detailsLabel: l10n.dashboardViewDetails,
                          onTap: (_) => context.goNamed(AppRouteNames.tasks),
                        ),
                        const SizedBox(height: 30),
                        DashboardSectionHeader(
                          title: l10n.dashboardRecentTasks,
                          actionLabel: l10n.dashboardViewAll,
                          onActionTap: () =>
                              context.goNamed(AppRouteNames.tasks),
                        ),
                        const SizedBox(height: 10),
                        DashboardFilterBar(
                          selected: _filter,
                          pendingLabel: l10n.dashboardPendingCount(2),
                          acceptedLabel: l10n.dashboardAcceptedCount(1),
                          completedLabel: l10n.dashboardCompletedFilter,
                          onSelected: (value) =>
                              setState(() => _filter = value),
                        ),
                        const SizedBox(height: 14),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _filter == DashboardTaskFilter.pending
                              ? Column(
                                  key: const ValueKey('pending-tasks'),
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
                                )
                              : DashboardEmptyState(
                                  key: ValueKey(_filter),
                                  label: l10n.dashboardNoFilteredTasks,
                                ),
                        ),
                        const SizedBox(height: 24),
                        DashboardPromoBanner(
                          title: l10n.dashboardGrowBusiness,
                          subtitle: l10n.dashboardGrowBusinessSubtitle,
                          actionLabel: l10n.dashboardBoostProfile,
                          onTap: () {
                            if (user?.isTasker == true) {
                              context.goNamed(
                                AppRouteNames.taskerProfile,
                                pathParameters: {'id': user!.id.toString()},
                              );
                            } else {
                              _showFeatureNotice(
                                  context, l10n.dashboardBoostProfile);
                            }
                          },
                        ),
                        const SizedBox(height: 24),
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
          SnackBar(content: Text(l10n.dashboardFeatureUnavailable(feature))));
  }

  Future<void> _showDashboardMenu(BuildContext context) async {
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
              leading: Icon(isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined),
              title: Text(
                  isDark ? l10n.dashboardLightMode : l10n.dashboardDarkMode),
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
