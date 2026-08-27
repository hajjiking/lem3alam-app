import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/dashboard_models.dart';

class DashboardPerformanceSection extends StatelessWidget {
  const DashboardPerformanceSection({
    super.key,
    required this.title,
    required this.earningsLabel,
    required this.earningsValue,
    required this.tasksCompletedLabel,
    required this.tasksCompletedValue,
    required this.earningsChangeLabel,
    required this.tasksChangeLabel,
    required this.selectedRange,
    required this.weekLabel,
    required this.monthLabel,
    required this.dayLabels,
    required this.points,
    required this.onRangeSelected,
    this.earningsChangePercent,
    this.tasksChangePercent,
    this.isAvailable = true,
    this.unavailableLabel = '',
  });

  final String title;
  final String earningsLabel;
  final String earningsValue;
  final String tasksCompletedLabel;
  final String tasksCompletedValue;
  final String earningsChangeLabel;
  final String tasksChangeLabel;
  final DashboardPerformanceRange selectedRange;
  final String weekLabel;
  final String monthLabel;
  final List<String> dayLabels;
  final List<WeeklyPerformancePoint> points;
  final ValueChanged<DashboardPerformanceRange> onRangeSelected;
  final num? earningsChangePercent;
  final num? tasksChangePercent;
  final bool isAvailable;
  final String unavailableLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rangeLabel = switch (selectedRange) {
      DashboardPerformanceRange.week => weekLabel,
      DashboardPerformanceRange.month => monthLabel,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            PopupMenuButton<DashboardPerformanceRange>(
              initialValue: selectedRange,
              onSelected: onRangeSelected,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: DashboardPerformanceRange.week,
                  child: Text(weekLabel),
                ),
                PopupMenuItem(
                  value: DashboardPerformanceRange.month,
                  child: Text(monthLabel),
                ),
              ],
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 12, 10),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.7)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(rangeLabel, style: theme.textTheme.labelLarge),
                    const SizedBox(width: 7),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: scheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!isAvailable)
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(unavailableLabel)))
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 700;
                  final metrics = Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _PerformanceMetric(
                          label: earningsLabel,
                          value: earningsValue,
                          changeLabel: earningsChangeLabel,
                          changePercent: earningsChangePercent,
                        ),
                      ),
                      VerticalDivider(color: scheme.outlineVariant),
                      Expanded(
                        child: _PerformanceMetric(
                          label: tasksCompletedLabel,
                          value: tasksCompletedValue,
                          changeLabel: tasksChangeLabel,
                          changePercent: tasksChangePercent,
                        ),
                      ),
                    ],
                  );
                  final chart =
                      _WeeklyChart(dayLabels: dayLabels, points: points);

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IntrinsicHeight(child: metrics),
                        const SizedBox(height: 22),
                        chart,
                      ],
                    );
                  }

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            flex: 4, child: IntrinsicHeight(child: metrics)),
                        const SizedBox(width: 22),
                        VerticalDivider(color: scheme.outlineVariant),
                        const SizedBox(width: 16),
                        Expanded(flex: 5, child: chart),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _PerformanceMetric extends StatelessWidget {
  const _PerformanceMetric({
    required this.label,
    required this.value,
    required this.changeLabel,
    required this.changePercent,
  });

  final String label;
  final String value;
  final String changeLabel;
  final num? changePercent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final trendColor = changePercent == null || changePercent == 0
        ? scheme.onSurfaceVariant
        : changePercent! < 0
            ? scheme.error
            : scheme.tertiary;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (changePercent != null) ...[
                Icon(
                    changePercent! < 0
                        ? Icons.arrow_downward_rounded
                        : changePercent! > 0
                            ? Icons.arrow_upward_rounded
                            : Icons.horizontal_rule_rounded,
                    color: trendColor,
                    size: 20),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  changeLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.dayLabels, required this.points});

  final List<String> dayLabels;
  final List<WeeklyPerformancePoint> points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      height: 178,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _WeeklyChartPainter(
                points: points,
                lineColor: scheme.primary,
                fillColor: scheme.primary.withValues(alpha: 0.10),
                gridColor: scheme.outlineVariant.withValues(alpha: 0.45),
                dotFillColor: scheme.surfaceContainerLowest,
                isRtl: isRtl,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final label in dayLabels)
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyChartPainter extends CustomPainter {
  const _WeeklyChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    required this.dotFillColor,
    required this.isRtl,
  });

  final List<WeeklyPerformancePoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final Color dotFillColor;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.isEmpty) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var index = 0; index < 3; index++) {
      final y = size.height * index / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = points.map((point) => point.value).reduce(math.max);
    final range = math.max(maxValue, 1.0);
    const verticalPadding = 8.0;
    final plotHeight = math.max(size.height - verticalPadding * 2, 1.0);
    final offsets = <Offset>[];

    for (var index = 0; index < points.length; index++) {
      final progress = points.length == 1 ? .5 : index / (points.length - 1);
      final x = (isRtl ? 1 - progress : progress) * size.width;
      final normalized = points[index].value / range;
      final y = verticalPadding + (1 - normalized) * plotHeight;
      offsets.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final point in offsets.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(offsets.last.dx, size.height)
      ..lineTo(offsets.first.dx, size.height)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final dotFill = Paint()..color = dotFillColor;
    final dotStroke = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final point in offsets) {
      canvas.drawCircle(point, 4, dotFill);
      canvas.drawCircle(point, 4, dotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.dotFillColor != dotFillColor ||
        oldDelegate.isRtl != isRtl;
  }
}
