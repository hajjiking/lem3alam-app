import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../domain/earnings_models.dart';
import 'transaction_row.dart';

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({super.key, required this.view});
  final EarningsView view;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                  child: Text(context.l10n.earningsTransactions,
                      style: Theme.of(context).textTheme.titleLarge)),
              TextButton(
                  onPressed: view.transactions.isEmpty
                      ? null
                      : () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (context) => SafeArea(
                              child: SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * .75,
                                  child: Column(children: [
                                    Text(context.l10n.earningsTransactions,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge),
                                    Expanded(
                                        child: ListView.separated(
                                            padding: const EdgeInsets.all(18),
                                            itemCount: view.transactions.length,
                                            separatorBuilder: (_, __) =>
                                                const Divider(),
                                            itemBuilder: (context, i) =>
                                                TransactionRow(
                                                    record:
                                                        view.transactions[i],
                                                    calculator: view.calculator,
                                                    currency:
                                                        view.ledger.currency)))
                                  ])))),
                  child: Text(context.l10n.dashboardViewAll))
            ]),
            if (view.transactions.isEmpty)
              Text(context.l10n.earningsNoTransactions),
            for (final record in view.transactions.take(5)) ...[
              const Divider(height: 1),
              TransactionRow(
                  record: record,
                  calculator: view.calculator,
                  currency: view.ledger.currency)
            ],
          ])));
}
