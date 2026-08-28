import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/dashboard_actions.dart';
import '../../dashboard/presentation/widgets/dashboard_header.dart';
import '../application/earnings_controller.dart';
import 'earnings_summary_card.dart';
import 'earnings_stats_row.dart';
import 'earnings_overview_chart.dart';
import 'earnings_category_donut.dart';
import 'platform_fees_info_card.dart';
import 'recent_transactions_card.dart';
import 'period_selector.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user?.isTasker != true) return const SizedBox.shrink();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(earningsControllerProvider);
    Future<void> refresh() async {
      try {
        await ref.read(earningsControllerProvider.notifier).refresh();
      } catch (_) {}
    }

    return RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: DashboardHeader(
                      appName: l10n.appName,
                      greeting: l10n.earningsTitle,
                      subtitle: l10n.earningsSubtitle,
                      availabilityLabel: '',
                      isOnline: false,
                      showAvailability: false,
                      compact: true,
                      avatarAsset: null,
                      titleActions: const PeriodSelector(),
                      menuLabel: l10n.dashboardMenu,
                      notificationsLabel: l10n.dashboardNotifications,
                      profileLabel: l10n.dashboardProfile,
                      onMenuTap: () => showDashboardMenu(context, ref),
                      onNotificationsTap: () => showDashboardFeatureNotice(
                          context, l10n.dashboardNotifications),
                      onProfileTap: () =>
                          openDashboardProfile(context, user?.id, true),
                      onAvailabilityTap: () {})),
              SliverToBoxAdapter(
                  child: state.when(
                      skipLoadingOnRefresh: false,
                      skipLoadingOnReload: false,
                      loading: () => const Padding(
                          padding: EdgeInsets.all(60),
                          child: Center(child: CircularProgressIndicator())),
                      error: (_, __) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(children: [
                            Text(l10n.earningsLoadError),
                            TextButton(
                                onPressed: refresh, child: Text(l10n.retry))
                          ])),
                      data: (view) => Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [
                                0,
                                .04
                              ],
                                  colors: [
                                theme
                                    .extension<Lem3alamThemeTokens>()!
                                    .headerEnd,
                                theme.scaffoldBackgroundColor
                              ])),
                          child: Center(
                              child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 1160),
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 0, 12, 24),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            EarningsSummaryCard(view: view),
                                            const SizedBox(height: 16),
                                            EarningsStatsRow(
                                                stats: view.ledger.stats),
                                            const SizedBox(height: 12),
                                            EarningsOverviewChart(view: view),
                                            const SizedBox(height: 12),
                                            EarningsCategoryDonut(view: view),
                                            PlatformFeesInfoCard(
                                                calculator: view.calculator),
                                            const SizedBox(height: 8),
                                            RecentTransactionsCard(view: view),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                child: Text(
                                                    l10n.earningsPrivate,
                                                    style: theme
                                                        .textTheme.bodySmall)),
                                          ]))))))),
            ]));
  }
}
