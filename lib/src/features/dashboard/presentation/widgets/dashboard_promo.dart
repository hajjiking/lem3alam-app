import 'package:flutter/material.dart';

class DashboardPromoBanner extends StatelessWidget {
  const DashboardPromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;
          final illustration = Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(24),
            ),
            child:
                Icon(Icons.campaign_outlined, color: scheme.primary, size: 54),
          );
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
          final action = FilledButton.icon(
            onPressed: onTap,
            label: Text(actionLabel),
            iconAlignment: IconAlignment.start,
            icon: const Icon(Icons.trending_up_rounded),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    illustration,
                    const SizedBox(width: 16),
                    Expanded(child: copy),
                  ],
                ),
                const SizedBox(height: 16),
                action,
              ],
            );
          }

          return Row(
            children: [
              illustration,
              const SizedBox(width: 20),
              Expanded(child: copy),
              const SizedBox(width: 20),
              action,
            ],
          );
        },
      ),
    );
  }
}
