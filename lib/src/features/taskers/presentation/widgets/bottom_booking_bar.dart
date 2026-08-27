import 'package:flutter/material.dart';

import '../../../../core/ui/app_theme.dart';

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
    final scheme = context.appColors;
    return Material(
      color: scheme.surfaceContainerLowest,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppStyle.pagePadding, vertical: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (priceHint != null || phoneHint != null) ...[
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    if (priceHint != null)
                      Text(priceHint!,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: scheme.primary)),
                    if (phoneHint != null)
                      Text(phoneHint!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton.icon(
                    onPressed: callEnabled ? onCall : null,
                    icon: const Icon(Icons.call_outlined, size: 20),
                    label: Text(callLabel),
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: FilledButton.icon(
                    onPressed: enabled ? onBookNow : null,
                    icon: const Icon(Icons.calendar_month_rounded, size: 20),
                    label: Text(bookLabel),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
