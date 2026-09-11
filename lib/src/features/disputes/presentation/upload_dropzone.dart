import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../domain/dispute_draft.dart';

class UploadDropzone extends StatelessWidget {
  const UploadDropzone({super.key, required this.onTap, this.small = false});
  final VoidCallback? onTap;
  final bool small;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return CustomPaint(
        foregroundPainter: _DashedBorder(c.primary),
        child: Material(
            color: c.primaryContainer.withValues(alpha: .3),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                    padding: EdgeInsets.all(small ? 8 : 24),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(small ? Icons.add : Icons.cloud_upload_outlined,
                              size: small ? 28 : 44, color: c.primary),
                          const SizedBox(height: 8),
                          Text(
                              small
                                  ? context.l10n.disputeAddMore
                                  : context.l10n.disputeTapUpload,
                              textAlign: TextAlign.center,
                              style: small
                                  ? Theme.of(context).textTheme.labelSmall
                                  : null),
                          if (!small) ...[
                            const SizedBox(height: 8),
                            Text(
                                context.l10n
                                    .disputeFormats(DisputeLimits.maxMegabytes),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: c.onSurfaceVariant))
                          ]
                        ])))));
  }
}

class _DashedBorder extends CustomPainter {
  _DashedBorder(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(12)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder oldDelegate) => color != oldDelegate.color;
}
