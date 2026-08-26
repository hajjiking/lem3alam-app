import 'package:flutter/material.dart';

class AdminCategoryViewData {
  const AdminCategoryViewData({
    required this.label,
    required this.count,
    required this.percent,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String count;
  final String percent;
  final IconData icon;
  final Color accent;
}

class AdminTopCategoriesCard extends StatelessWidget {
  const AdminTopCategoriesCard({
    super.key,
    required this.title,
    required this.viewAllLabel,
    required this.items,
    required this.onViewAll,
    required this.onCategoryTap,
  });

  final String title;
  final String viewAllLabel;
  final List<AdminCategoryViewData> items;
  final VoidCallback onViewAll;
  final ValueChanged<int> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
                TextButton(onPressed: onViewAll, child: Text(viewAllLabel)),
              ],
            ),
            const SizedBox(height: 6),
            for (var index = 0; index < items.length; index++)
              _CategoryRow(
                data: items[index],
                onTap: () => onCategoryTap(index),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.data, required this.onTap});

  final AdminCategoryViewData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tintAlpha = theme.brightness == Brightness.dark ? 0.18 : 0.10;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 7),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: data.accent.withValues(alpha: tintAlpha),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(data.icon, color: data.accent, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(width: 10),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(data.count, style: theme.textTheme.titleMedium),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 47,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  data.percent,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
