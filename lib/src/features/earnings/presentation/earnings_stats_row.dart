import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../domain/earnings_models.dart';

class EarningsStatsRow extends StatelessWidget {
  const EarningsStatsRow({super.key, required this.stats});
  final EarningsStat stats;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tokens = theme.extension<Lem3alamThemeTokens>()!;
    final format = NumberFormat.decimalPattern(l10n.localeName);
    final change = stats.completedTasks - stats.previousCompletedTasks;
    final items = [
      (
        l10n.dashboardTasksCompleted,
        format.format(stats.completedTasks),
        l10n.earningsCompletedChange(
            '${change > 0 ? '+' : ''}${format.format(change)}'),
        Icons.trending_up,
        tokens.success
      ),
      (
        l10n.statusInProgress,
        format.format(stats.inProgressCount),
        l10n.earningsActiveNow,
        Icons.calendar_month_outlined,
        theme.colorScheme.primary
      ),
      (
        l10n.earningsRating,
        stats.averageRating == null
            ? '—'
            : NumberFormat.decimalPatternDigits(
                    locale: l10n.localeName, decimalDigits: 1)
                .format(stats.averageRating),
        l10n.earningsReviewCount(format.format(stats.reviewCount)),
        Icons.star_rounded,
        tokens.warning
      ),
      (
        l10n.earningsJobs,
        format.format(stats.totalJobsAllTime),
        l10n.earningsAllTime,
        Icons.work_outline,
        tokens.accentPurple
      ),
    ];
    return LayoutBuilder(builder: (context, c) {
      final count = c.maxWidth >= 850
          ? 4
          : c.maxWidth >= 300
              ? 2
              : 1;
      return Wrap(spacing: 12, runSpacing: 12, children: [
        for (var i = 0; i < items.length; i++)
          SizedBox(
              width: (c.maxWidth - (count - 1) * 12) / count,
              child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                                backgroundColor:
                                    items[i].$5.withValues(alpha: .12),
                                child: Icon(items[i].$4, color: items[i].$5)),
                            const SizedBox(height: 12),
                            Text(items[i].$1),
                            Text(items[i].$2,
                                style: theme.textTheme.headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            if (i == 2 && stats.averageRating != null)
                              FittedBox(
                                  child: Row(children: [
                                for (var star = 1; star <= 5; star++)
                                  Icon(
                                      stats.averageRating! >= star
                                          ? Icons.star
                                          : stats.averageRating! >= star - .5
                                              ? Icons.star_half
                                              : Icons.star_border,
                                      color: tokens.warning,
                                      size: 18)
                              ])),
                            Text(items[i].$3,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: i == 0 && change < 0
                                        ? theme.colorScheme.error
                                        : items[i].$5)),
                          ]))))
      ]);
    });
  }
}
