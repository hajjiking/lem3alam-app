import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../../../routing/app_router.dart';
import '../domain/earnings_models.dart';
import '../domain/fee_calculator.dart';
import 'earnings_format.dart';

class TransactionRow extends StatelessWidget {
  const TransactionRow(
      {super.key,
      required this.record,
      required this.calculator,
      required this.currency,
      this.details = false});
  final TransactionRecord record;
  final FeeCalculator calculator;
  final String currency;
  final bool details;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isEstimate = record.status == TransactionStatus.inProgress;
    final amounts = record.amounts(calculator);
    final green = theme.extension<Lem3alamThemeTokens>()!.success;
    final tone = isEstimate ? theme.colorScheme.primary : green;
    final date = DateFormat.yMMMd(l10n.localeName).format(record.date);
    final description = Row(children: [
      CircleAvatar(
          radius: 16,
          backgroundColor: tone.withValues(alpha: .12),
          child: Icon(isEstimate ? Icons.schedule : Icons.check,
              color: tone, size: 20)),
      const SizedBox(width: 10),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(record.taskTitle, style: theme.textTheme.titleSmall),
        Text(
            isEstimate
                ? l10n.earningsEstimatedOn(date)
                : l10n.earningsPaidOn(date),
            style: theme.textTheme.bodySmall)
      ])),
    ]);
    final values = [
      (
        isEstimate ? l10n.earningsExpected : l10n.earningsGrossLabel,
        amounts.gross,
        tone
      ),
      (
        isEstimate ? l10n.earningsEstimatedFee : l10n.earningsFeeLabel,
        -amounts.fee,
        theme.colorScheme.error
      ),
      (
        isEstimate ? l10n.earningsEstimatedNet : l10n.earningsNetLabel,
        amounts.net,
        tone
      )
    ];
    final figures = LayoutBuilder(builder: (context, c) {
      final width =
          c.maxWidth < 300 ? (c.maxWidth - 12) / 2 : (c.maxWidth - 24) / 3;
      return Wrap(spacing: 12, runSpacing: 8, children: [
        for (final v in values)
          SizedBox(
              width: width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.$1, style: theme.textTheme.labelSmall),
                    EarningsMoney(v.$2,
                        currency: currency,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: v.$3, fontWeight: FontWeight.w700))
                  ]))
      ]);
    });
    return InkWell(
        onTap: details
            ? null
            : () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (sheetContext) => SafeArea(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(l10n.earningsDetails,
                              style: theme.textTheme.titleLarge),
                          const SizedBox(height: 16),
                          TransactionRow(
                              record: record,
                              calculator: calculator,
                              currency: currency,
                              details: true),
                          const SizedBox(height: 16),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                context.pushNamed(AppRouteNames.taskDetail,
                                    pathParameters: {'id': '${record.taskId}'});
                              },
                              child: Text(l10n.dashboardViewDetails)),
                        ])))),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: LayoutBuilder(builder: (context, c) {
              if (c.maxWidth < 680) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      description,
                      const SizedBox(height: 12),
                      figures
                    ]);
              }
              return Row(children: [
                Expanded(flex: 4, child: description),
                const SizedBox(width: 20),
                Expanded(flex: 5, child: figures),
                if (!details) const Icon(Icons.chevron_right)
              ]);
            })));
  }
}
