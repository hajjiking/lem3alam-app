import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import '../../../core/l10n/l10n.dart';
import '../domain/earnings_models.dart';
import 'earnings_format.dart';
import 'period_selector.dart';

class EarningsOverviewChart extends StatelessWidget {
  const EarningsOverviewChart(
      {super.key, required this.view, this.showMarkers = false});
  final EarningsView view;
  final bool showMarkers;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = view.points;
    final maxValue =
        math.max(10000, (view.summary.net / 10000).ceil() * 10000).toDouble();
    final dates = DateFormat(
        view.ledger.period == EarningsPeriod.thisYear ? 'MMM' : 'd MMM',
        context.l10n.localeName);
    final ticks = points.length <= 4
        ? points
        : List.generate(
            4, (i) => points[(i * (points.length - 1) / 3).round()]);
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
                                  Text(context.l10n.earningsOverview,
                                      style: theme.textTheme.titleLarge),
                                  const SizedBox(height: 12),
                                  const PeriodSelector(),
                                ])
                          : Row(children: [
                              Expanded(
                                  child: Text(context.l10n.earningsOverview,
                                      style: theme.textTheme.titleLarge)),
                              const SizedBox(
                                  width: 250, child: PeriodSelector())
                            ])),
                  const SizedBox(height: 8),
                  Text(context.l10n.earningsCumulative,
                      style: theme.textTheme.bodySmall),
                  const SizedBox(height: 18),
                  if (view.summary.gross == 0)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(context.l10n.earningsEmpty)),
                  SizedBox(
                      height: 180,
                      child: Row(children: [
                        SizedBox(
                            width: 76,
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  for (var i = 4; i >= 0; i--)
                                    Text(
                                        NumberFormat.compactCurrency(
                                                locale: context.l10n.localeName,
                                                name: view.ledger.currency,
                                                symbol: view.ledger.currency,
                                                decimalDigits: 0)
                                            .format(maxValue * i / 4 / 100),
                                        textDirection: TextDirection.ltr,
                                        style: theme.textTheme.labelSmall),
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
                              Flexible(
                                  child: Text(dates.format(p.date),
                                      style: theme.textTheme.labelSmall))
                          ])),
                  ExpansionTile(
                      title: Text(context.l10n.earningsChartData),
                      children: [
                        for (final p in points)
                          ListTile(
                              dense: true,
                              title: Text(dates.format(p.date)),
                              trailing: EarningsMoney(p.net,
                                  currency: view.ledger.currency))
                      ]),
                ])));
  }
}

// The existing app uses themed CustomPainter charts; this keeps the same
// rendering approach without introducing another charting dependency.
class _EarningsLinePainter extends CustomPainter {
  _EarningsLinePainter(
      this.points, this.maximum, this.color, this.grid, this.rtl, this.markers);
  final List<EarningsChartPoint> points;
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
            (1 - points[i].net / maximum) * size.height)
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
