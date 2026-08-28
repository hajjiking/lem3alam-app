import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import '../l10n/l10n.dart';
import '../domain/money_chart_point.dart';
export '../domain/money_chart_point.dart';

import '../../features/earnings/presentation/earnings_format.dart';

class MoneyOverviewChart extends StatelessWidget {
  const MoneyOverviewChart(
      {super.key,
      required this.points,
      required this.total,
      required this.currency,
      required this.title,
      required this.subtitle,
      required this.emptyLabel,
      required this.periodSelector,
      required this.monthly,
      this.showMarkers = false});
  final List<MoneyChartPoint> points;
  final int total;
  final String currency, title, subtitle, emptyLabel;
  final Widget periodSelector;
  final bool monthly;
  final bool showMarkers;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = math.max(10000, (total / 10000).ceil() * 10000).toDouble();
    final dates =
        DateFormat(monthly ? 'MMM' : 'd MMM', context.l10n.localeName);
    final tickCount = MediaQuery.sizeOf(context).width < 500 ? 3 : 4;
    final ticks = points.length <= tickCount
        ? points
        : List.generate(tickCount,
            (i) => points[(i * (points.length - 1) / (tickCount - 1)).round()]);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                      builder: (context, c) => c.maxWidth < 580
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                  Text(title,
                                      style: theme.textTheme.titleLarge),
                                  const SizedBox(height: 12),
                                  periodSelector,
                                ])
                          : Row(children: [
                              Expanded(
                                  child: Text(title,
                                      style: theme.textTheme.titleLarge)),
                              SizedBox(width: 250, child: periodSelector)
                            ])),
                  const SizedBox(height: 8),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 18),
                  if (total == 0)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(emptyLabel)),
                  SizedBox(
                      height: 180 *
                          math.max(1,
                              MediaQuery.textScalerOf(context).scale(14) / 14),
                      child: Row(children: [
                        SizedBox(
                            width: 76,
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  for (var i = 4; i >= 0; i--)
                                    FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                            NumberFormat.compactCurrency(
                                                    locale:
                                                        context.l10n.localeName,
                                                    name: currency,
                                                    symbol: currency,
                                                    decimalDigits: 0)
                                                .format(maxValue * i / 4 / 100),
                                            textDirection: TextDirection.ltr,
                                            style: theme.textTheme.labelSmall)),
                                ])),
                        const SizedBox(width: 8),
                        Expanded(
                            child: CustomPaint(
                                painter: _EarningsLinePainter(
                                    points,
                                    maxValue,
                                    theme.colorScheme.primary,
                                    theme.colorScheme.outlineVariant,
                                    Directionality.of(context) ==
                                        TextDirection.rtl,
                                    showMarkers),
                                child: const SizedBox.expand()))
                      ])),
                  const SizedBox(height: 8),
                  Padding(
                      padding: const EdgeInsetsDirectional.only(start: 84),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final p in ticks)
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(dates.format(p.date),
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.labelSmall)))
                          ])),
                  ExpansionTile(
                      title: Text(context.l10n.earningsChartData),
                      children: [
                        for (final p in points)
                          ListTile(
                              dense: true,
                              title: Text(dates.format(p.date)),
                              trailing:
                                  EarningsMoney(p.value, currency: currency))
                      ]),
                ])));
  }
}

// The existing app uses themed CustomPainter charts; this keeps the same
// rendering approach without introducing another charting dependency.
class _EarningsLinePainter extends CustomPainter {
  _EarningsLinePainter(
      this.points, this.maximum, this.color, this.grid, this.rtl, this.markers);
  final List<MoneyChartPoint> points;
  final double maximum;
  final Color color, grid;
  final bool rtl, markers;
  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          Paint()
            ..color = grid.withValues(alpha: .5)
            ..strokeWidth = 1);
    }
    if (points.isEmpty || size.isEmpty) return;
    final offsets = [
      for (var i = 0; i < points.length; i++)
        Offset(
            (rtl
                    ? 1 - (points.length == 1 ? .5 : i / (points.length - 1))
                    : (points.length == 1 ? .5 : i / (points.length - 1))) *
                size.width,
            (1 - points[i].value / maximum) * size.height)
    ];
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final p in offsets.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final area = Path.from(path)
      ..lineTo(offsets.last.dx, size.height)
      ..lineTo(offsets.first.dx, size.height)
      ..close();
    canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: .18),
                color.withValues(alpha: .02)
              ]).createShader(Offset.zero & size));
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round);
    if (markers || offsets.length == 1) {
      for (final p in offsets) {
        canvas.drawCircle(p, 3, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EarningsLinePainter old) =>
      old.points != points ||
      old.maximum != maximum ||
      old.color != color ||
      old.grid != grid ||
      old.rtl != rtl ||
      old.markers != markers;
}
