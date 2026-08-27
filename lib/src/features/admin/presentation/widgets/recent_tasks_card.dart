import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AdminRecentTaskViewData {
  const AdminRecentTaskViewData({
    required this.title,
    required this.customerLabel,
    required this.statusLabel,
    required this.timeLabel,
    required this.thumbnailUrl,
    required this.statusColor,
    required this.fallbackIcon,
  });

  final String title;
  final String customerLabel;
  final String statusLabel;
  final String timeLabel;
  final String thumbnailUrl;
  final Color statusColor;
  final IconData fallbackIcon;
}

class AdminRecentTasksCard extends StatelessWidget {
  const AdminRecentTasksCard({
    super.key,
    required this.title,
    required this.viewAllLabel,
    required this.viewAllTasksLabel,
    required this.items,
    required this.onViewAll,
    required this.onTaskTap,
  });

  final String title;
  final String viewAllLabel;
  final String viewAllTasksLabel;
  final List<AdminRecentTaskViewData> items;
  final VoidCallback onViewAll;
  final ValueChanged<int> onTaskTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
                TextButton(onPressed: onViewAll, child: Text(viewAllLabel)),
              ],
            ),
            const SizedBox(height: 4),
            for (var index = 0; index < items.length; index++) ...[
              _RecentTaskRow(
                data: items[index],
                onTap: () => onTaskTap(index),
              ),
              if (index != items.length - 1)
                Divider(color: scheme.outlineVariant.withValues(alpha: 0.45)),
            ],
            const SizedBox(height: 6),
            Divider(color: scheme.outlineVariant.withValues(alpha: 0.55)),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onViewAll,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        viewAllTasksLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      textDirection: Directionality.of(context),
                      color: scheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTaskRow extends StatelessWidget {
  const _RecentTaskRow({required this.data, required this.onTap});

  final AdminRecentTaskViewData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusAlpha = theme.brightness == Brightness.dark ? 0.19 : 0.10;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 58,
                height: 58,
                child: data.thumbnailUrl.isEmpty
                    ? ColoredBox(
                        color: scheme.surfaceContainer,
                        child: Icon(data.fallbackIcon, color: scheme.primary))
                    : CachedNetworkImage(
                        imageUrl: data.thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => ColoredBox(
                          color: scheme.surfaceContainer,
                          child: Icon(data.fallbackIcon, color: scheme.primary),
                        ),
                        errorWidget: (context, url, error) => ColoredBox(
                          color: scheme.surfaceContainer,
                          child: Icon(data.fallbackIcon, color: scheme.primary),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.customerLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 106),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 5),
                    decoration: BoxDecoration(
                      color: data.statusColor.withValues(alpha: statusAlpha),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      data.statusLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: data.statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.timeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
