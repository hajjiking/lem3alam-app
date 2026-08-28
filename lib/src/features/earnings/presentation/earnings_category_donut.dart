import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../../admin/presentation/widgets/tasks_status_donut.dart';
import '../domain/earnings_models.dart';
import 'earnings_format.dart';

class EarningsCategoryDonut extends StatelessWidget {
  const EarningsCategoryDonut({super.key, required this.view});
  final EarningsView view;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<Lem3alamThemeTokens>()!;
    final colors = [
      theme.colorScheme.primary,
      tokens.success,
      tokens.accentPurple,
      tokens.warning
    ];
    return TasksStatusDonut(
        title: context.l10n.earningsCategory,
        totalLabel: context.l10n.earningsNet,
        totalValue:
            earningsMoney(context, view.summary.net, view.ledger.currency),
        items: [
          for (var i = 0; i < view.categoryEarnings.length; i++)
            AdminStatusLegendData(
                label: view.categoryEarnings[i].name ??
                    context.l10n.earningsUncategorized,
                value: earningsMoney(context,
                    view.categoryEarnings[i].amounts.net, view.ledger.currency),
                percentLabel: '${view.categoryEarnings[i].percent}%',
                color: colors[i % colors.length],
                chartValue: view.categoryEarnings[i].amounts.net.toDouble()),
        ]);
  }
}
