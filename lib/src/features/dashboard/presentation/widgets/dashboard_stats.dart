import 'package:flutter/material.dart';

class DashboardStatViewData {
  const DashboardStatViewData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.secondaryLabel,
    this.labelIcon,
  });

  final String label;
  final String value;
  final String? secondaryLabel;
  final IconData icon;
  final IconData? labelIcon;
  final Color accent;
}

class DashboardStatsRow extends StatelessWidget {
  const DashboardStatsRow({super.key, required this.items});

  final List<DashboardStatViewData> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return SizedBox(
            height: 208,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  if (index > 0) const SizedBox(width: 14),
                  Expanded(child: _DashboardStatCard(data: items[index])),
                ],
              ],
            ),
          );
        }

        return SizedBox(
          height: 208,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.only(end: 4),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: 174,
              child: _DashboardStatCard(data: items[index]),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({required this.data});

  final DashboardStatViewData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      label: '${data.label}: ${data.value}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            data.accent.withValues(alpha: 0.055),
            scheme.surfaceContainerLowest,
          ),
          borderRadius: BorderRadius.circular(22),
          border:
              Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: data.accent,
                boxShadow: [
                  BoxShadow(
                    color: data.accent.withValues(alpha: 0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(data.icon, size: 30, color: scheme.onPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              data.value,
              maxLines: 1,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    data.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                ),
                if (data.labelIcon != null) ...[
                  const SizedBox(width: 4),
                  Icon(data.labelIcon, size: 18, color: data.accent),
                ],
              ],
            ),
            if (data.secondaryLabel != null) ...[
              const SizedBox(height: 3),
              Text(
                data.secondaryLabel!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: data.accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
