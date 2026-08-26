import 'package:flutter/material.dart';

class AdminMetricCardData {
  const AdminMetricCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.deltaValue,
    this.deltaCaption,
    this.isPositive,
  });

  final String label;
  final String value;
  final String? deltaValue;
  final String? deltaCaption;
  final IconData icon;
  final Color accent;
  final bool? isPositive;
}

class AdminMetricCard extends StatelessWidget {
  const AdminMetricCard({
    super.key,
    required this.data,
    required this.detailsLabel,
    required this.onTap,
  });

  final AdminMetricCardData data;
  final String detailsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final trendColor = data.isPositive == true ? scheme.tertiary : scheme.error;
    final tintAlpha = theme.brightness == Brightness.dark ? 0.18 : 0.10;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: data.accent.withValues(alpha: tintAlpha),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(data.icon, color: data.accent, size: 27),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              data.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (data.deltaValue != null && data.deltaCaption != null) ...[
                const SizedBox(height: 9),
                Row(
                  children: [
                    Icon(
                      data.isPositive == true
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: trendColor,
                      size: 17,
                    ),
                    const SizedBox(width: 3),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        data.deltaValue!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: trendColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        data.deltaCaption!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              Divider(color: scheme.outlineVariant.withValues(alpha: 0.55)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      detailsLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    textDirection: Directionality.of(context),
                    color: scheme.onSurfaceVariant,
                    size: 21,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
