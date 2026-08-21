import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.icon,
    required this.name,
    this.startingPrice,
    this.currency = 'MAD',
    this.estimatedDuration,
    this.onBook,
    this.color,
    this.bookLabel = 'Book',
    this.heroTag,
  });

  final IconData icon;
  final String name;
  final int? startingPrice;
  final String currency;
  final String? estimatedDuration;
  final VoidCallback? onBook;
  final Color? color;
  final String bookLabel;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;
    final card = Container(
      width: 280,
      height: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 24, color: accent),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                textStyle: Theme.of(context).textTheme.titleMedium,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (startingPrice != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'From $startingPrice $currency',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (estimatedDuration != null)
                Expanded(
                  child: Text(
                    estimatedDuration!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onBook,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    bookLabel,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: heroTag == null ? card : Hero(tag: heroTag!, child: card),
    );
  }
}
