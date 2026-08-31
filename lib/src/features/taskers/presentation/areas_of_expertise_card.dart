import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';

class AreasOfExpertiseCard extends StatelessWidget {
  const AreasOfExpertiseCard({
    super.key,
    required this.items,
    this.onViewAll,
  });

  final List<String> items;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              title: l10n.publicProfileAreasExpertise,
              viewAll: l10n.publicProfileViewAll,
              onViewAll: onViewAll,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 560 ? 2 : 1;
              final width = columns == 2
                  ? (constraints.maxWidth - 24) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 24,
                runSpacing: 10,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: width,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              size: 19,
                              color: Theme.of(context).colorScheme.tertiary),
                          const SizedBox(width: 9),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.viewAll,
    required this.onViewAll,
  });
  final String title;
  final String viewAll;
  final VoidCallback? onViewAll;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
              child:
                  Text(title, style: Theme.of(context).textTheme.titleLarge)),
          TextButton(onPressed: onViewAll ?? () {}, child: Text(viewAll)),
        ],
      );
}
