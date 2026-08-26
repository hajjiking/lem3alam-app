import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticCard extends StatelessWidget {
  const StatisticCard({
    super.key,
    required this.items,
    this.columns,
    this.padding = const EdgeInsets.all(20),
  }) : assert(items.length > 0);

  final List<StatisticItem> items;
  final int? columns;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cross = columns ?? _columnsForWidth(constraints.maxWidth);
        final perColumn = (items.length / cross).ceil();
        final rows = List.generate(perColumn, (row) {
          return Row(
            children: List.generate(cross, (col) {
              final i = row * cross + col;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    col == 0 ? 0 : 8,
                    row == 0 ? 0 : 16,
                    0,
                    0,
                  ),
                  child: i < items.length
                      ? _Tile(item: items[i])
                      : const SizedBox.shrink(),
                ),
              );
            }),
          );
        });
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          padding: padding,
          child: Column(
            children: rows,
          ),
        );
      },
    );
  }

  static int _columnsForWidth(double width) {
    if (width >= 720) return 4;
    if (width >= 480) return 2;
    return 2;
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item});
  final StatisticItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = item.accent ?? scheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, size: 20, color: accent),
        ),
        const SizedBox(height: 10),
        Text(
          item.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            textStyle: Theme.of(context).textTheme.titleMedium,
            fontWeight: FontWeight.w900,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class StatisticItem {
  const StatisticItem({
    required this.icon,
    required this.label,
    required this.value,
    this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? accent;
}
