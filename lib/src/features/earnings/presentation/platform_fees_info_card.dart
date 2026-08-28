import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import '../../../core/l10n/l10n.dart';
import '../domain/fee_calculator.dart';

class PlatformFeesInfoCard extends StatelessWidget {
  const PlatformFeesInfoCard({super.key, required this.calculator});
  final FeeCalculator calculator;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Card(
        color: scheme.primaryContainer.withValues(alpha: .5),
        child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_rounded, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(l10n.earningsFeeInfo,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: scheme.primary)),
                    Text(l10n.earningsFeeBody(
                        NumberFormat.decimalPattern(l10n.localeName)
                            .format(calculator.platformFeeRate * 100))),
                    const SizedBox(height: 8),
                    Text(l10n.earningsEstimateBasis,
                        style: Theme.of(context).textTheme.bodySmall),
                  ])),
              const SizedBox(width: 12),
              Icon(Icons.verified_user_outlined,
                  color: scheme.primary, size: 32),
            ])));
  }
}
