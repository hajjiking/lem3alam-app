import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/money_overview_chart.dart';
import '../domain/earnings_models.dart';
import 'period_selector.dart';

class EarningsOverviewChart extends StatelessWidget {
  const EarningsOverviewChart(
      {super.key, required this.view, this.showMarkers = false});
  final EarningsView view;
  final bool showMarkers;
  @override
  Widget build(BuildContext context) => MoneyOverviewChart(
      points: [for (final p in view.points) MoneyChartPoint(p.date, p.net)],
      total: view.summary.net,
      currency: view.ledger.currency,
      title: context.l10n.earningsOverview,
      subtitle: context.l10n.earningsCumulative,
      emptyLabel: context.l10n.earningsEmpty,
      periodSelector: const PeriodSelector(),
      monthly: view.ledger.period == EarningsPeriod.thisYear,
      showMarkers: showMarkers);
}
