import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n.dart';
import '../domain/dispute_draft.dart';

class DisputeSubmittedStep extends StatelessWidget {
  const DisputeSubmittedStep({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = Theme.of(context).colorScheme;
    final next = [
      l.disputeTimeline(DisputeLimits.reviewDays),
      l.disputeContact,
      l.disputeResolution
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 24),
      SizedBox(
          height: 128,
          child: Stack(alignment: Alignment.center, children: [
            CircleAvatar(
                radius: 48,
                backgroundColor: c.tertiaryContainer,
                child: Icon(Icons.check_rounded, size: 60, color: c.tertiary)),
            for (final offset in [
              const Offset(-85, -40),
              const Offset(88, -36),
              const Offset(-104, 28),
              const Offset(98, 32)
            ])
              Transform.translate(
                  offset: offset,
                  child: Icon(Icons.auto_awesome, size: 12, color: c.tertiary))
          ])),
      const SizedBox(height: 20),
      Text(l.disputeSuccess,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text(l.disputeSuccessBody(DisputeLimits.reviewDays),
          textAlign: TextAlign.center),
      const SizedBox(height: 18),
      _info(
          context,
          Row(children: [
            Icon(Icons.mail_outline, color: c.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(l.disputeNotification))
          ])),
      const SizedBox(height: 20),
      FilledButton(
          onPressed: () => context.go('/disputes'), child: Text(l.disputeView)),
      const SizedBox(height: 10),
      OutlinedButton.icon(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.home_outlined),
          label: Text(l.disputeHome)),
      const SizedBox(height: 20),
      _info(
          context,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.disputeWhatNext,
                style: Theme.of(context).textTheme.titleSmall),
            for (var i = 0; i < next.length; i++)
              Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                            radius: 16,
                            backgroundColor: c.surfaceContainerHighest,
                            foregroundColor: c.onSurface,
                            child: Text('${i + 1}')),
                        const SizedBox(width: 12),
                        Expanded(child: Text(next[i]))
                      ]))
          ])),
    ]);
  }

  Widget _info(BuildContext context, Widget child) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: .35),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
      child: child);
}
