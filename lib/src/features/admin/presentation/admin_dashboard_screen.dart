import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/widgets/dashboard_header.dart';
import 'admin_dashboard_controller.dart';
import 'widgets/metric_card.dart';
import 'widgets/metrics_grid.dart';

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
    final tokens = theme.extension<Lem3alamThemeTokens>()!;
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final summaryAsync = ref.watch(adminDashboardProvider);
    final rawName = auth.user?.name.trim() ?? '';
    final displayName = rawName.isEmpty
        ? l10n.adminDefaultName
        : rawName.split(RegExp(r'\s+')).first;
    final numberFormat = NumberFormat.decimalPattern(l10n.localeName);
    final currencyFormat = NumberFormat.currency(
      locale: l10n.localeName,
      name: 'MAD',
      symbol: '${l10n.dashboardCurrencyMad} ',
      decimalDigits: 0,
    );

    final metrics = summaryAsync.maybeWhen(
      data: (summary) => <AdminMetricCardData>[
        AdminMetricCardData(
          label: l10n.adminTotalUsers,
          value: numberFormat.format(summary.usersCount),
          icon: Icons.people_alt_rounded,
          accent: scheme.primary,
        ),
        AdminMetricCardData(
          label: l10n.adminTotalTasks,
          value: numberFormat.format(summary.tasksCount),
          icon: Icons.assignment_turned_in_rounded,
          accent: scheme.tertiary,
        ),
        AdminMetricCardData(
          label: l10n.openDisputes,
          value: numberFormat.format(summary.disputesCount),
          icon: Icons.gavel_rounded,
          accent: scheme.error,
        ),
        AdminMetricCardData(
          label: l10n.revenue,
          value: currencyFormat.format(summary.revenue),
          icon: Icons.payments_outlined,
          accent: tokens.warning,
        ),
      ],
      orElse: () => const <AdminMetricCardData>[],
    );

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
            availabilityLabel: l10n.dashboardOffline,
            isOnline: false,
            showAvailability: false,
            menuLabel: l10n.dashboardMenu,
            notificationsLabel: l10n.dashboardNotifications,
            profileLabel: l10n.dashboardProfile,
            avatarAsset: null,
            avatarFallback: Icons.admin_panel_settings_rounded,
            onMenuTap: onMenuTap,
            onNotificationsTap: onNotificationsTap,
            onProfileTap: onProfileTap,
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
                        const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (summaryAsync.isLoading)
                          const AppSkeletonBox(height: 390)
                        else if (summaryAsync.hasError)
                          AppErrorState(
                            title: l10n.unableToLoadAdminOverview,
                            subtitle: l10n.checkConnectionOrAdminPermissions,
                            debugDetails: summaryAsync.error.toString(),
                            onRetry: () => ref
                                .read(adminActionControllerProvider.notifier)
                                .refreshAll(),
                          )
                        else ...[
                          AdminMetricsGrid(
                            items: metrics,
                            detailsLabel: l10n.dashboardViewDetails,
                            onSelected: (index) => _showFeatureNotice(
                              context,
                              metrics[index].label,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppInlineBanner(
                            message: l10n.adminDetailedAnalyticsUnavailable,
                            tone: AppBannerTone.info,
                            icon: Icons.query_stats_rounded,
                          ),
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.dashboardFeatureUnavailable(feature)),
        ),
      );
  }
}
