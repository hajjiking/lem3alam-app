import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_theme.dart';
import '../../domain/client_dashboard_stats.dart';
import 'dashboard_stats.dart';

class ClientStatsRow extends StatelessWidget {
  const ClientStatsRow(
      {super.key,
      required this.stats,
      required this.onActiveTap,
      required this.onCompletedTap,
      required this.onSuccessTap});

  final ClientDashboardStats stats;
  final VoidCallback onActiveTap;
  final VoidCallback onCompletedTap;
  final VoidCallback onSuccessTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final numbers = NumberFormat.decimalPattern(l10n.localeName);
    final percentage = NumberFormat.percentPattern(l10n.localeName)
      ..maximumFractionDigits = 2;
    final items = [
      DashboardStatViewData(
          label: l10n.dashboardActiveTasks,
          value: numbers.format(stats.activeTasks),
          icon: Icons.business_center_outlined,
          accent: context.appColors.primary),
      DashboardStatViewData(
          label: l10n.dashboardCompleted,
          value: numbers.format(stats.completedTasks),
          icon: Icons.star_outline_rounded,
          accent: context.appTokens.success),
      DashboardStatViewData(
          label: l10n.dashboardSuccessRate,
          value: stats.successRate == null
              ? '—'
              : percentage.format(stats.successRate! / 100),
          icon: Icons.bar_chart_rounded,
          accent: context.appTokens.warning),
    ];
    final actions = [onActiveTap, onCompletedTap, onSuccessTap];
    return LayoutBuilder(builder: (context, constraints) {
      // Wrap instead of fixed-height cards so translations and text scaling fit.
      final columns = constraints.maxWidth >= 840
          ? 3
          : constraints.maxWidth >= 500
              ? 2
              : 1;
      return Wrap(spacing: 14, runSpacing: 14, children: [
        for (var i = 0; i < items.length; i++)
          SizedBox(
              width: (constraints.maxWidth - 14 * (columns - 1)) / columns,
              child: DashboardDetailStatCard(
                  data: items[i],
                  actionLabel: l10n.dashboardViewDetails,
                  onTap: actions[i])),
      ]);
    });
  }
}
