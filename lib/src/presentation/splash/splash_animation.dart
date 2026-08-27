import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';

class SplashAnimationValues {
  SplashAnimationValues({
    required Animation<double> parent,
  })  : backgroundFade = CurvedAnimation(
          parent: parent,
          curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
        ),
        logoScale = Tween<double>(begin: .15, end: 1.0).animate(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(.08, .38, curve: Curves.elasticOut),
          ),
        ),
        logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(.08, .22),
          ),
        ),
        logoSlide = Tween<Offset>(
          begin: const Offset(0, .5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(.08, .38, curve: Curves.easeOutCubic),
          ),
        ),
        logoRotation = Tween<double>(begin: -0.08, end: 0.0).animate(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(.08, .45, curve: Curves.easeOutBack),
          ),
        ),
        logoPulse = TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.04, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(.38, .70, curve: Curves.easeInOut),
          ),
        ),
        glowPulse = TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.22, end: 0.40), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.40, end: 0.22), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.22, end: 0.35), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.35, end: 0.22), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(.30, .75, curve: Curves.easeInOut),
          ),
        ),
        textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(.32, .48),
          ),
        ),
        textScale = Tween<double>(begin: 0.7, end: 1.0).animate(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(.32, .50, curve: Curves.easeOutBack),
          ),
        ),
        taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(.42, .58, curve: Curves.easeIn),
          ),
        ),
        taglineSlide = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(.42, .60, curve: Curves.easeOutCubic),
          ),
        ),
        loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(.55, .72, curve: Curves.easeInOut),
          ),
        ),
        backgroundGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: parent,
            curve: const Interval(.05, .30, curve: Curves.easeOut),
          ),
        );

  final Animation<double> backgroundFade;
  final Animation<double> logoScale;
  final Animation<double> logoOpacity;
  final Animation<Offset> logoSlide;
  final Animation<double> logoRotation;
  final Animation<double> logoPulse;
  final Animation<double> glowPulse;
  final Animation<double> textOpacity;
  final Animation<double> textScale;
  final Animation<double> taglineOpacity;
  final Animation<Offset> taglineSlide;
  final Animation<double> loadingOpacity;
  final Animation<double> backgroundGlow;
}

class SplashBackground extends StatelessWidget {
  const SplashBackground({
    super.key,
    required this.child,
    required this.patternOpacity,
    required this.glowProgress,
  });

  final Widget child;
  final double patternOpacity;
  final double glowProgress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.appColors.surface,
            context.appColors.surfaceContainerLow
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: Opacity(
              opacity: patternOpacity,
              child: CustomPaint(
                painter: MoroccanPatternPainter(
                  color: context.appColors.primary.withValues(
                    alpha: isDark ? 0.08 : 0.06,
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.1,
                    colors: [
                      context.appColors.secondary.withValues(
                        alpha: isDark ? 0.12 : 0.18 * glowProgress,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class MoroccanPatternPainter extends CustomPainter {
  const MoroccanPatternPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 46.0;
    final rows = (size.height / spacing).ceil() + 2;
    final cols = (size.width / spacing).ceil() + 2;
    final radius = spacing * 0.34;

    for (var row = -1; row < rows; row++) {
      for (var col = -1; col < cols; col++) {
        final center = Offset(
          col * spacing + (row.isEven ? 0 : spacing / 2),
          row * spacing,
        );
        canvas.drawPath(_buildRosette(center, radius), paint);
      }
    }
  }

  Path _buildRosette(Offset center, double radius) {
    final path = Path();

    for (var i = 0; i < 8; i++) {
      final outerAngle = (-math.pi / 2) + (i * math.pi / 4);
      final innerAngle = outerAngle + (math.pi / 8);
      final outer = Offset(
        center.dx + math.cos(outerAngle) * radius,
        center.dy + math.sin(outerAngle) * radius,
      );
      final inner = Offset(
        center.dx + math.cos(innerAngle) * radius * 0.7,
        center.dy + math.sin(innerAngle) * radius * 0.7,
      );

      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant MoroccanPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
