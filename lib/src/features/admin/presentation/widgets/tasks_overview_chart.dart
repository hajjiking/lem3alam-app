import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/admin_dashboard_models.dart';

class AdminChartLegendItem {
  const AdminChartLegendItem({required this.label, required this.color});

  final String label;
  final Color color;
}

class TasksOverviewChart extends StatelessWidget {
  const TasksOverviewChart({
    super.key,
    required this.title,
    required this.rangeLabel,
    required this.points,
    required this.dayLabels,
    required this.legendItems,
    required this.onRangeTap,
  });

  final String title;
  final String rangeLabel;
  final List<TaskSeriesPoint> points;
  final List<String> dayLabels;
  final List<AdminChartLegendItem> legendItems;
  final VoidCallback onRangeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onRangeTap,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 10, 8),
                  ),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                  label: Text(rangeLabel),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 22,
              runSpacing: 8,
              children: [
                for (final item in legendItems)
                  _LegendDot(label: item.label, color: item.color),
              ],
            ),
            const SizedBox(height: 14),
            Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                height: 230,
                child: Column(
                  children: [
                    Expanded(
                      child: CustomPaint(
                        painter: _TasksLineChartPainter(
                          points: points,
                          postedColor: legendItems[0].color,
                          inProgressColor: legendItems[1].color,
                          completedColor: legendItems[2].color,
                          gridColor:
                              scheme.outlineVariant.withValues(alpha: 0.48),
                          labelColor: scheme.onSurfaceVariant,
                          labelStyle: theme.textTheme.labelSmall,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 37),
                      child: Row(
                        children: [
                          for (final label in dayLabels)
                            Expanded(
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _TasksLineChartPainter extends CustomPainter {
  const _TasksLineChartPainter({
    required this.points,
    required this.postedColor,
    required this.inProgressColor,
    required this.completedColor,
    required this.gridColor,
    required this.labelColor,
    required this.labelStyle,
  });

  final List<TaskSeriesPoint> points;
  final Color postedColor;
  final Color inProgressColor;
  final Color completedColor;
  final Color gridColor;
  final Color labelColor;
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    const left = 37.0;
    const top = 8.0;
    const bottom = 4.0;
    final chartWidth = math.max(0.0, size.width - left);
    final chartHeight = math.max(0.0, size.height - top - bottom);
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var index = 0; index <= 4; index++) {
      final value = index * 200;
      final y = top + chartHeight - (value / 800) * chartHeight;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), gridPaint);
      final painter = TextPainter(
        text: TextSpan(
          text: '$value',
          style: (labelStyle ?? const TextStyle()).copyWith(
            color: labelColor,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: left - 5);
      painter.paint(
          canvas, Offset(left - painter.width - 7, y - painter.height / 2));
    }

    void drawSeries(double Function(TaskSeriesPoint) readValue, Color color) {
      final path = Path();
      final pointPaint = Paint()..color = color;
      for (var index = 0; index < points.length; index++) {
        final x = points.length == 1
            ? left + chartWidth / 2
            : left + (chartWidth * index / (points.length - 1));
        final normalized = (readValue(points[index]) / 800).clamp(0.0, 1.0);
        final y = top + chartHeight - normalized * chartHeight;
        if (index == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        canvas.drawCircle(Offset(x, y), 4, pointPaint);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    drawSeries((point) => point.posted, postedColor);
    drawSeries((point) => point.inProgress, inProgressColor);
    drawSeries((point) => point.completed, completedColor);
  }

  @override
  bool shouldRepaint(covariant _TasksLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.postedColor != postedColor ||
        oldDelegate.inProgressColor != inProgressColor ||
        oldDelegate.completedColor != completedColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.labelColor != labelColor;
  }
}
