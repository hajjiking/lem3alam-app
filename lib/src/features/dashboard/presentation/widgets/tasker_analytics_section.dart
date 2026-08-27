import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/dashboard_models.dart';
import 'dashboard_performance.dart';

class TaskerAnalyticsSection extends StatelessWidget {
  const TaskerAnalyticsSection(
      {super.key,
      required this.snapshot,
      required this.range,
      required this.onRangeSelected});
  final DashboardSnapshot snapshot;
  final DashboardPerformanceRange range;
  final ValueChanged<DashboardPerformanceRange> onRangeSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final performance = range == DashboardPerformanceRange.week
        ? (snapshot.hasPerformance ? snapshot.performance : null)
        : snapshot.monthlyPerformance;
    final points = performance?.points ?? const <WeeklyPerformancePoint>[];
    final numbers = NumberFormat.decimalPattern(l10n.localeName);
    final weekdays = [
      l10n.mon,
      l10n.tue,
      l10n.wed,
      l10n.thu,
      l10n.fri,
      l10n.sat,
      l10n.sun
    ];
    String label(WeeklyPerformancePoint point) => point.date != null
        ? DateFormat.Md(l10n.localeName).format(point.date!)
        : weekdays[point.dayIndex % 7];
    final labels = points.length <= 7
        ? points.map(label).toList()
        : List.generate(
            6,
            (index) =>
                label(points[(index * (points.length - 1) / 5).round()]));
    String comparison(num? value) => value == null
        ? l10n.taskerNoComparison
        : l10n.taskerPeriodChange(numbers.format(value));

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DashboardPerformanceSection(
        title: l10n.dashboardPerformance,
        earningsLabel: l10n.dashboardEarnings,
        earningsValue: performance == null
            ? '—'
            : l10n.dashboardPrice(numbers.format(performance.earnings)),
        tasksCompletedLabel: l10n.dashboardTasksCompleted,
        tasksCompletedValue: performance == null
            ? '—'
            : numbers.format(performance.tasksCompleted),
        earningsChangeLabel: comparison(performance?.earningsChangePercent),
        tasksChangeLabel: comparison(performance?.tasksChangePercent),
        earningsChangePercent: performance?.earningsChangePercent,
        tasksChangePercent: performance?.tasksChangePercent,
        selectedRange: range,
        weekLabel: l10n.dashboardThisWeek,
        monthLabel: l10n.dashboardThisMonth,
        points: points,
        dayLabels: labels,
        onRangeSelected: onRangeSelected,
        isAvailable: performance != null,
        unavailableLabel: l10n.taskerPeriodUnavailable,
      ),
      if (performance != null) ...[
        const SizedBox(height: 8),
        Text(l10n.taskerAnalyticsPrivate,
            style: Theme.of(context).textTheme.bodySmall),
        if (performance.earnings == 0 && performance.tasksCompleted == 0)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.taskerNoActivity)),
        ExpansionTile(
            key: const PageStorageKey('tasker-analytics-chart-data'),
            title: Text(l10n.adminChartData),
            children: [
              for (final point in points)
                ListTile(
                    title: Text(label(point)),
                    subtitle: Text(
                        '${l10n.dashboardEarnings}: ${l10n.dashboardPrice(numbers.format(point.value))} · ${l10n.dashboardTasksCompleted}: ${point.tasksCompleted == null ? '—' : numbers.format(point.tasksCompleted)}')),
            ]),
      ],
    ]);
  }
}
