import 'package:flutter/material.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';

class BadgeChip extends StatelessWidget {
  const BadgeChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    this.border,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.leading,
  });

  factory BadgeChip.verified(BuildContext context, String label) {
    final primary = Theme.of(context).colorScheme.primary;
    return BadgeChip(
      label: label,
      icon: Icons.verified_user_rounded,
      backgroundColor: primary.withValues(alpha: 0.10),
      foregroundColor: primary,
      iconColor: primary,
    );
  }

  factory BadgeChip.topRated(BuildContext context, String label) {
    final c = context.appTokens.warning;
    return BadgeChip(
      label: label,
      icon: Icons.emoji_events_rounded,
      backgroundColor: context.appTokens.warning.withValues(alpha: 0.12),
      foregroundColor: c,
      iconColor: c,
    );
  }

  factory BadgeChip.experience(BuildContext context, String label) {
    final c = context.appTokens.accentPurple;
    return BadgeChip(
      label: label,
      icon: Icons.workspace_premium_rounded,
      backgroundColor: c.withValues(alpha: 0.10),
      foregroundColor: c,
      iconColor: c,
    );
  }

  factory BadgeChip.availableToday(BuildContext context, String label) {
    final c = context.appTokens.success;
    return BadgeChip(
      label: label,
      icon: Icons.check_circle_rounded,
      backgroundColor: context.appTokens.success.withValues(alpha: 0.12),
      foregroundColor: c,
      iconColor: c,
    );
  }

  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? iconColor;
  final BoxBorder? border;
  final EdgeInsets padding;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ??
        scheme.surfaceContainerHighest.withValues(alpha: 0.8);
    final fg = foregroundColor ?? scheme.onSurface;
    final ic = iconColor ?? fg;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: border ??
            Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) leading!,
          if (icon != null) ...[
            Icon(icon, size: 14, color: ic),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
