import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomBookingBar extends StatelessWidget {
  const BottomBookingBar({
    super.key,
    required this.onCall,
    required this.onBookNow,
    this.callLabel = 'Call',
    this.bookLabel = 'Book Now',
    this.phoneHint,
    this.priceHint,
    this.enabled = true,
    this.callEnabled = true,
  });

  final VoidCallback? onCall;
  final VoidCallback? onBookNow;
  final String callLabel;
  final String bookLabel;
  final String? phoneHint;
  final String? priceHint;
  final bool enabled;
  final bool callEnabled;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: 0.99),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + media.padding.bottom),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(
              top: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.4)),
            ),
          ),
          child: Row(
            children: [
              if (phoneHint != null || priceHint != null) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (priceHint != null)
                          Text(
                            priceHint!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              textStyle: Theme.of(context).textTheme.titleLarge,
                              fontWeight: FontWeight.w900,
                              color: scheme.primary,
                            ),
                          ),
                        if (phoneHint != null)
                          Text(
                            phoneHint!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: scheme.onSurfaceVariant,
                                    ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              OutlinedButton.icon(
                onPressed: callEnabled ? onCall : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(110, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                icon: const Icon(Icons.call_outlined, size: 20),
                label: Text(
                  callLabel,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: enabled ? onBookNow : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded, size: 20),
                  label: Text(
                    bookLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, letterSpacing: 0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
