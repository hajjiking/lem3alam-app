import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n.dart';
import '../application/earnings_controller.dart';
import '../domain/earnings_models.dart';

class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Semantics(
      label: context.l10n.earningsPeriod,
      child: DropdownButtonFormField<EarningsPeriod>(
          key: ValueKey(ref.watch(earningsPeriodProvider)),
          value: ref.watch(earningsPeriodProvider),
          isExpanded: true,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_month_outlined),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface),
          items: [
            for (final p in EarningsPeriod.values)
              DropdownMenuItem(
                  value: p,
                  child: Text(
                      switch (p) {
                        EarningsPeriod.thisMonth =>
                          context.l10n.dashboardThisMonth,
                        EarningsPeriod.lastMonth =>
                          context.l10n.earningsLastMonth,
                        EarningsPeriod.thisYear =>
                          context.l10n.earningsThisYear,
                      },
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis))
          ],
          onChanged: (p) {
            if (p != null) ref.read(earningsPeriodProvider.notifier).select(p);
          }));
}
