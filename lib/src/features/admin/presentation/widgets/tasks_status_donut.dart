import 'dart:math' as math;

import 'package:flutter/material.dart';

class AdminStatusLegendData {
  const AdminStatusLegendData({
    required this.label,
    required this.value,
    required this.percentLabel,
    required this.color,
    required this.chartValue,
  });

  final String label;
  final String value;
  final String percentLabel;
  final Color color;
  final double chartValue;
}

class TasksStatusDonut extends StatelessWidget {
  const TasksStatusDonut({
    super.key,
    required this.title,
    required this.totalLabel,
    required this.totalValue,
    required this.items,
  });

  final String title;
  final String totalLabel;
  final String totalValue;
  final List<AdminStatusLegendData> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 190,
                height: 190,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      painter: _DonutPainter(
                        values: items
                            .map((item) => item.chartValue)
                            .toList(growable: false),
                        colors: items
                            .map((item) => item.color)
                            .toList(growable: false),
                        trackColor: theme.colorScheme.surfaceContainerHigh,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              totalValue,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            totalLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            for (final item in items) ...[
              _StatusLegendRow(item: item),
              if (item != items.last) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusLegendRow extends StatelessWidget {
  const _StatusLegendRow({required this.item});

  final AdminStatusLegendData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(item.label, style: theme.textTheme.bodyMedium)),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            '${item.value} (${item.percentLabel})',
            style: theme.textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.values,
    required this.colors,
    required this.trackColor,
  });

  final List<double> values;
  final List<Color> colors;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 13;
    const strokeWidth = 31.0;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      bounds,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    final total = values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return;
    const gap = 0.025;
    var start = -math.pi / 2;
    for (var index = 0; index < values.length; index++) {
      final sweep = math.pi * 2 * values[index] / total;
      canvas.drawArc(
        bounds,
        start + gap / 2,
        math.max(0, sweep - gap),
        false,
        Paint()
          ..color = colors[index]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.colors != colors ||
        oldDelegate.trackColor != trackColor;
  }
}
