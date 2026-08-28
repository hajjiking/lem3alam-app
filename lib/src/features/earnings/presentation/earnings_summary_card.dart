import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../domain/earnings_models.dart';
import 'earnings_format.dart';

class EarningsSummaryCard extends StatelessWidget {
  const EarningsSummaryCard({super.key, required this.view});
  final EarningsView view;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final positive = theme.extension<Lem3alamThemeTokens>()!.success;
    final amount = view.summary;
    final delta = view.deltaPercent;
    final total =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.earningsTotal, style: theme.textTheme.titleMedium),
      const SizedBox(height: 12),
      EarningsMoney(amount.net,
          currency: view.ledger.currency,
          style: theme.textTheme.headlineLarge
              ?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text(
          delta == null
              ? l10n.earningsNoComparison
              : l10n.earningsComparison(
                  '${delta > 0 ? '+' : ''}${NumberFormat.decimalPatternDigits(locale: l10n.localeName, decimalDigits: 1).format(delta)}'),
          style: TextStyle(
              color: delta == null || delta == 0
                  ? scheme.onSurfaceVariant
                  : delta > 0
                      ? positive
                      : scheme.error)),
    ]);
    final breakdown =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.earningsGross),
      EarningsMoney(amount.gross,
          currency: view.ledger.currency,
          style: TextStyle(color: positive, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      Text(l10n.earningsFees),
      EarningsMoney(-amount.fee,
          currency: view.ledger.currency,
          style: TextStyle(color: scheme.error)),
      const Divider(),
      Text(l10n.earningsNet),
      EarningsMoney(amount.net,
          currency: view.ledger.currency,
          style: theme.textTheme.titleLarge
              ?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800)),
    ]);
    final balance = InkWell(
        onTap: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text(l10n.earningsBalance),
                    content: Text(l10n.earningsBalanceUnavailable),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.close))
                    ])),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(l10n.earningsBalance),
                    const SizedBox(height: 8),
                    if (view.ledger.availableBalance == null)
                      Text('—', style: theme.textTheme.titleLarge)
                    else
                      EarningsMoney(view.ledger.availableBalance!,
                          currency: view.ledger.currency)
                  ])),
              const Icon(Icons.chevron_right),
            ])));
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(22),
            child: LayoutBuilder(builder: (context, c) {
              if (c.maxWidth < 720) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      total,
                      const Divider(height: 32),
                      breakdown,
                      const Divider(height: 32),
                      balance
                    ]);
              }
              return Row(children: [
                Expanded(flex: 4, child: total),
                const SizedBox(width: 24),
                CircleAvatar(
                    radius: 32,
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.account_balance_wallet_outlined,
                        size: 32, color: scheme.primary)),
                const SizedBox(width: 24),
                Expanded(flex: 3, child: breakdown),
                const SizedBox(width: 24),
                SizedBox(
                    height: 170,
                    child: VerticalDivider(color: scheme.outlineVariant)),
                const SizedBox(width: 24),
                Expanded(flex: 3, child: balance)
              ]);
            })));
  }
}
