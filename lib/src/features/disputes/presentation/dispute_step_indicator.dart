import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';

class DisputeStepIndicator extends StatelessWidget {
  const DisputeStepIndicator({super.key, required this.step});
  final int step;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = Theme.of(context).colorScheme;
    final labels = [
      l.disputeDetails,
      l.disputeEvidence,
      l.disputeReview,
      l.disputeSubmitted
    ];
    // Row follows Directionality: index zero is always the reading-start edge.
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
                child: Column(children: [
              Row(children: [
                Expanded(
                    child:
                        Divider(color: i == 0 ? c.surface : c.outlineVariant)),
                Semantics(
                    label: labels[i],
                    selected: i == step,
                    child: CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            i <= step ? c.primary : c.surfaceContainerHighest,
                        foregroundColor:
                            i <= step ? c.onPrimary : c.onSurfaceVariant,
                        child: i < step
                            ? const Icon(Icons.check, size: 18)
                            : Text('${i + 1}'))),
                Expanded(
                    child:
                        Divider(color: i == 3 ? c.surface : c.outlineVariant))
              ]),
              const SizedBox(height: 8),
              Text(labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: i == step ? c.primary : c.onSurfaceVariant))
            ]))
        ]));
  }
}
