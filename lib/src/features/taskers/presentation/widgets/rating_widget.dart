import 'package:flutter/material.dart';
import '../../../../core/ui/app_theme.dart';

class RatingWidget extends StatelessWidget {
  const RatingWidget({
    super.key,
    required this.rating,
    this.size = 18,
    this.activeColor,
    this.inactiveColor,
    this.showHalf = true,
  });

  final double rating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showHalf;

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? context.appTokens.warning;
    final ic = inactiveColor ??
        Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.7);
    final r = rating.clamp(0.0, 5.0);
    final full = r.floor();
    final fraction = r - full;
    final hasHalf = showHalf && fraction >= 0.25 && fraction < 0.75;
    final halfAsFull = !showHalf && fraction >= 0.5;
    final totalFull = full + (halfAsFull ? 1 : 0);
    final half = hasHalf ? 1 : 0;
    final empty = 5 - totalFull - half;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < totalFull; i++)
          Padding(
            padding: EdgeInsets.only(
                right: i < totalFull - 1 || half > 0 || empty > 0 ? 2 : 0),
            child: Icon(Icons.star_rounded, size: size, color: active),
          ),
        if (half == 1)
          Padding(
            padding: EdgeInsets.only(right: empty > 0 ? 2 : 0),
            child: Stack(
              children: [
                Icon(Icons.star_rounded, size: size, color: ic),
                ClipRect(
                  clipper: const _HalfClipper(),
                  child: Icon(Icons.star_rounded, size: size, color: active),
                ),
              ],
            ),
          ),
        for (var i = 0; i < empty; i++)
          Padding(
            padding: EdgeInsets.only(right: i < empty - 1 ? 2 : 0),
            child: Icon(Icons.star_rounded, size: size, color: ic),
          ),
      ],
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  const _HalfClipper();
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width / 2, size.height);
  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
