import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';

import '../l10n/l10n.dart';
import 'app_theme.dart';
import '../networking/api_client.dart';

class AppResponsiveCenter extends StatelessWidget {
  const AppResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor,
    this.shadow = true,
    this.elevation,
    this.surfaceTintColor,
    this.shape,
    this.margin,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool shadow;
  final double? elevation;
  final Color? surfaceTintColor;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: margin,
      color: backgroundColor,
      elevation: elevation ?? (shadow ? null : 0),
      surfaceTintColor: surfaceTintColor,
      shadowColor: shadow ? null : Colors.transparent,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: backgroundColor == Colors.transparent && !shadow
                  ? colorScheme.outlineVariant.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1,
            ),
          ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing!,
                  ],
                ],
              ),
            if (title != null) const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.fillColor,
    this.border,
    this.focusNode,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;
  final Color? fillColor;
  final InputBorder? border;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(18);
    final effectiveBorder = border ??
        OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        );

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: fillColor ?? colorScheme.surfaceContainerLowest,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onTap: onTap,
          readOnly: readOnly,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 14, end: 10),
              child: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant, size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            suffixIcon: suffixIcon,
            filled: false,
            border: effectiveBorder,
            enabledBorder: effectiveBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: Lem3alamColors.primaryBlue, width: 1.8),
            ),
          ),
        ),
      ),
    );
  }
}

class AppLocationChip extends StatelessWidget {
  const AppLocationChip({
    super.key,
    required this.location,
    this.subtitle,
    this.onTap,
  });

  final String location;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: Lem3alamColors.primaryBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(Icons.location_on_rounded, color: Lem3alamColors.primaryBlue, size: 18),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.onSurfaceVariant, size: 22),
          ],
        ),
      ),
    );
  }
}

class AppHeroPromoCard extends StatelessWidget {
  const AppHeroPromoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    this.onCtaTap,
    this.backgroundColor,
    this.icon,
    this.iconAsset,
    this.heroCutoutImageUrl,
    this.heroCutoutAssetPath,
  });

  static const String kDefaultArtisanCutoutAsset = 'assets/artisan_cutout.png';

  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback? onCtaTap;
  final Color? backgroundColor;
  final IconData? icon;
  final String? iconAsset;
  final String? heroCutoutImageUrl;
  final String? heroCutoutAssetPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? Lem3alamColors.primaryBlue;
    final onBg = bg.computeLuminance() > 0.55 ? colorScheme.onSurface : Colors.white;
    final resolvedAsset = heroCutoutAssetPath ?? kDefaultArtisanCutoutAsset;
    final useCutout = heroCutoutImageUrl != null || resolvedAsset.isNotEmpty;
    final compact = MediaQuery.sizeOf(context).width < 380;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxVisual = compact ? 190.0 : 230.0;
        final minVisual = compact ? 168.0 : 190.0;
        final visualHeight = (maxVisual * (constraints.maxWidth.clamp(280, 1080) / 1080) + maxVisual * 0.78).clamp(minVisual, maxVisual + 14);
        return Container(
          constraints: BoxConstraints(minHeight: visualHeight + 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bg, bg.withValues(alpha: 0.84)],
            ),
            boxShadow: [
              BoxShadow(
                color: bg.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              Positioned(
                top: -54,
                right: -16,
                child: Container(
                  height: 270,
                  width: 270,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.09),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -78,
                left: -64,
                child: Container(
                  height: 240,
                  width: 240,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              if (useCutout)
                PositionedDirectional(
                  end: -2,
                  bottom: -8,
                  child: SizedBox(
                    height: visualHeight,
                    width: (visualHeight * 0.82).clamp(110.0, 195.0),
                    child: _HeroArtisanCutout(
                      imageUrl: heroCutoutImageUrl,
                      assetPath: resolvedAsset,
                      fallbackIcon: icon ?? Icons.handyman_rounded,
                      fallbackColor: onBg,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 22, useCutout ? (compact ? 124 : 172) : 14, 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: onBg,
                                  fontWeight: FontWeight.w900,
                                  height: 1.22,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            maxLines: useCutout ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: onBg.withValues(alpha: 0.88)),
                          ),
                          const SizedBox(height: 14),
                          FilledButton.tonalIcon(
                            onPressed: onCtaTap,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Lem3alamColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(ctaLabel),
                          ),
                        ],
                      ),
                    ),
                    if (!useCutout) ...[
                      const SizedBox(width: 10),
                      Container(
                        height: 120,
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: iconAsset != null
                            ? Image.asset(iconAsset!, fit: BoxFit.cover)
                            : Icon(icon ?? Icons.handyman_rounded, color: onBg, size: 62),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroArtisanCutout extends StatelessWidget {
  const _HeroArtisanCutout({
    this.imageUrl,
    this.assetPath,
    required this.fallbackIcon,
    required this.fallbackColor,
  });

  final String? imageUrl;
  final String? assetPath;
  final IconData fallbackIcon;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    final useAsset = assetPath != null && assetPath!.isNotEmpty;
    final useNetwork = imageUrl != null && imageUrl!.isNotEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                radius: 1.0,
                colors: [
                  Colors.white.withValues(alpha: 0.20),
                  Colors.white.withValues(alpha: 0.00),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Builder(
              builder: (context) {
                if (useNetwork) {
                  return Image.network(
                    imageUrl!,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: SizedBox.square(
                          dimension: 26,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => _buildFallback(),
                  );
                }
                if (useAsset) {
                  return Image.asset(
                    assetPath!,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    errorBuilder: (_, __, ___) => _buildFallback(),
                  );
                }
                return _buildFallback();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Container(
        height: 96,
        width: 90,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(fallbackIcon, color: fallbackColor, size: 54),
      ),
    );
  }
}


class AppCategoryTile extends StatelessWidget {
  const AppCategoryTile({
    super.key,
    required this.label,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = iconBackgroundColor ?? colorScheme.surfaceContainerLow;
    final fg = iconColor ?? Lem3alamColors.primaryBlue;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(icon ?? Icons.category_outlined, color: fg, size: 24),
            ),
            const SizedBox(height: 6),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onActionTap != null) ...[
          const SizedBox(width: 10),
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(actionLabel!),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class AppRoleCard extends StatelessWidget {
  const AppRoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = accentColor ?? (selected ? Lem3alamColors.primaryBlue : colorScheme.primary);
    final bg = selected
        ? accent.withValues(alpha: 0.08)
        : colorScheme.surfaceContainerLowest;
    final border = selected
        ? Border.all(color: accent, width: 1.6)
        : Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55));

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(26),
          border: border,
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(22),
              ),
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.fromLTRB(12, 8, 10, 10),
              child: Icon(icon, color: accent, size: 76),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class AppSegmentedTabBar<T> extends StatelessWidget {
  const AppSegmentedTabBar({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  final List<AppSegmentedTab<T>> tabs;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            Expanded(
              child: _segment(
                context: context,
                tab: tab,
                selected: selected == tab.value,
              ),
            ),
        ],
      ),
    );
  }

  Widget _segment({
    required BuildContext context,
    required AppSegmentedTab<T> tab,
    required bool selected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: selected ? Colors.white : colorScheme.onSurfaceVariant,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onSelected(tab.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Lem3alamColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Lem3alamColors.primaryBlue.withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(tab.label, style: textStyle),
        ),
      ),
    );
  }
}

class AppSegmentedTab<T> {
  const AppSegmentedTab({required this.value, required this.label});

  final T value;
  final String label;
}

class AppInlineBanner extends StatelessWidget {
  const AppInlineBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.tone = AppBannerTone.error,
  });

  final String message;
  final IconData icon;
  final AppBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      AppBannerTone.error => (colorScheme.errorContainer, colorScheme.onErrorContainer),
      AppBannerTone.warning => (colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
      AppBannerTone.info => (colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
      AppBannerTone.success => (colorScheme.primaryContainer, colorScheme.onPrimaryContainer),
      AppBannerTone.neutral => (colorScheme.surfaceContainerHigh, colorScheme.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

enum AppBannerTone { error, warning, info, success, neutral }

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    this.tone = AppBannerTone.neutral,
    this.icon,
  });

  final String label;
  final AppBannerTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      AppBannerTone.error => (colorScheme.errorContainer, colorScheme.onErrorContainer),
      AppBannerTone.warning => (colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
      AppBannerTone.info => (colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
      AppBannerTone.success => (
          Lem3alamColors.accentGreen.withValues(alpha: 0.14),
          Lem3alamColors.accentGreen,
        ),
      AppBannerTone.neutral => (
          colorScheme.surfaceContainerHigh,
          colorScheme.onSurfaceVariant,
        ),
    };

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        icon != null ? 8 : 12,
        7,
        12,
        7,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 14),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: AppResponsiveCenter(
        maxWidth: 520,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(icon, color: colorScheme.onSecondaryContainer, size: 34),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.add),
                      label: Text(actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onRetry,
    this.debugDetails,
    this.retryLabel = 'Retry',
  });

  final String title;
  final String subtitle;
  final VoidCallback onRetry;
  final String? debugDetails;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: AppResponsiveCenter(
        maxWidth: 560,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(Icons.cloud_off_outlined, color: colorScheme.onErrorContainer, size: 34),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  if (kDebugMode && debugDetails != null && debugDetails!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      debugDetails!,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(retryLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.label,
    this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class AppStarRating extends StatelessWidget {
  const AppStarRating({
    super.key,
    required this.rating,
    this.size = 18,
    this.color,
    this.showHalf = true,
  });

  final double rating;
  final double size;
  final Color? color;
  final bool showHalf;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? const Color(0xFFF59E0B);
    final dim = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final idx = i.toDouble();
        final remains = rating - idx;
        IconData iconData;
        Color fillColor;
        if (remains >= 0.75) {
          iconData = Icons.star_rounded;
          fillColor = accent;
        } else if (remains >= 0.25 && showHalf) {
          iconData = Icons.star_half_rounded;
          fillColor = accent;
        } else {
          iconData = Icons.star_outline_rounded;
          fillColor = dim;
        }
        return Padding(
          padding: EdgeInsets.only(right: i == 4 ? 0 : 1),
          child: Icon(iconData, size: size, color: fillColor),
        );
      }),
    );
  }
}

class AppProfileBadgePill extends StatelessWidget {
  const AppProfileBadgePill({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.backgroundColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? scheme.primary.withValues(alpha: 0.08);
    final fg = labelColor ?? scheme.primary;
    final ic = iconColor ?? scheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.08), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: ic),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppServicePriceRow extends StatelessWidget {
  const AppServicePriceRow({
    super.key,
    required this.service,
    this.price,
    this.priceText,
    this.currency = 'MAD',
  });

  final String service;
  final int? price;
  final String? priceText;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final showPrice = price != null || (priceText ?? '').isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              service,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: scheme.onSurface),
            ),
          ),
          if (showPrice) ...[
            const SizedBox(width: 12),
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  priceText ?? '$price $currency',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: scheme.primary,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppReviewSummaryCard extends StatelessWidget {
  const AppReviewSummaryCard({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.distribution,
    this.starColor,
  });

  final double averageRating;
  final int totalReviews;
  final Map<int, int> distribution;
  final Color? starColor;

  @override
  Widget build(BuildContext context) {
    final star = starColor ?? const Color(0xFFF59E0B);
    final scheme = Theme.of(context).colorScheme;
    final total = distribution.values.fold<int>(0, (a, b) => a + b);
    final safeTotal = total == 0 ? 1 : total;
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 520;
        final children = [
          SizedBox(
            width: stacked ? double.infinity : 180,
            child: Column(
              crossAxisAlignment: stacked ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: scheme.onSurface,
                        height: 1,
                      ),
                ),
                const SizedBox(height: 10),
                AppStarRating(rating: averageRating, size: 22, color: star, showHalf: true),
                const SizedBox(height: 8),
                Text(
                  totalReviews <= 0
                      ? context.l10n.noReviewsYet
                      : context.l10n.reviewsCount(
                          averageRating.toStringAsFixed(1),
                          totalReviews,
                        ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (stacked) const SizedBox(height: 14) else const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final starCount = 5 - i;
                final count = distribution[starCount] ?? 0;
                final fraction = count / safeTotal;
                return Padding(
                  padding: EdgeInsets.only(bottom: i == 4 ? 0 : 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 42,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              starCount.toString(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Icon(Icons.star_rounded, size: 15, color: star),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 10,
                            backgroundColor: scheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(star),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 36,
                        child: Text(
                          count.toString(),
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ];
        return AppSectionCard(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: stacked ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: children) : Row(children: children),
        );
      },
    );
  }
}

class AppReviewTile extends StatelessWidget {
  const AppReviewTile({
    super.key,
    required this.reviewerName,
    this.reviewerAvatarUrl,
    required this.rating,
    required this.text,
    required this.relativeDate,
    this.starColor,
  });

  final String reviewerName;
  final String? reviewerAvatarUrl;
  final double rating;
  final String text;
  final String relativeDate;
  final Color? starColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(23),
            ),
            child: reviewerAvatarUrl == null || reviewerAvatarUrl!.trim().isEmpty
                ? Icon(Icons.person_outline, color: scheme.onSurfaceVariant, size: 26)
                : Image.network(
                    reviewerAvatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.person_outline, color: scheme.onSurfaceVariant, size: 26),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        reviewerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        relativeDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AppStarRating(rating: rating, size: 17, color: starColor, showHalf: true),
                    const SizedBox(width: 8),
                    Text(
                      rating.toStringAsFixed(1),
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFFF59E0B)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppProfileBackFavShareBar extends StatelessWidget {
  const AppProfileBackFavShareBar({
    super.key,
    this.onBack,
    this.onFavorite,
    this.onShare,
    this.isFavorite = false,
  });

  final VoidCallback? onBack;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
      child: Row(
        children: [
          _profileActionButton(
            context: context,
            icon: Icons.arrow_back_rounded,
            onTap: onBack ?? () => Navigator.maybePop(context),
            semantics: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          const Spacer(),
          _profileActionButton(
            context: context,
            icon: isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
            onTap: onFavorite,
            semantics: context.l10n.save,
            color: isFavorite ? const Color(0xFFEF4444) : null,
          ),
          const SizedBox(width: 10),
          _profileActionButton(
            context: context,
            icon: Icons.share_outlined,
            onTap: onShare,
            semantics: 'Share',
          ),
        ],
      ),
    );
  }

  Widget _profileActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onTap,
    required String semantics,
    Color? color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: semantics,
      enabled: onTap != null,
      child: Material(
        color: scheme.surface.withValues(alpha: 0.92),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Icon(
              icon,
              size: 22,
              color: color ?? scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class AppProfileActionBar extends StatelessWidget {
  const AppProfileActionBar({
    super.key,
    this.chatLabel,
    this.bookLabel,
    this.onChat,
    this.onBook,
    this.bookEnabled = true,
    this.chatEnabled = true,
  });

  final String? chatLabel;
  final String? bookLabel;
  final VoidCallback? onChat;
  final VoidCallback? onBook;
  final bool bookEnabled;
  final bool chatEnabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final media = MediaQuery.paddingOf(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + media.bottom),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: chatEnabled ? onChat : null,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: Text(chatLabel ?? l10n.chat),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: bookEnabled ? onBook : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.event_available_rounded),
              label: Text(bookLabel ?? l10n.bookService),
            ),
          ),
        ],
      ),
    );
  }
}

String appRelativeDateFromIso(String iso, AppLocalizations l10n) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  final now = DateTime.now().toUtc();
  final diff = now.difference(dt);
  if (diff.inDays >= 365) {
    final y = diff.inDays ~/ 365;
    return '${y}y';
  }
  if (diff.inDays >= 92) {
    final m = (diff.inDays / 30).round();
    return '${m}mo';
  }
  if (diff.inDays >= 7) {
    final w = diff.inDays ~/ 7;
    return l10n.weeksAgo(w);
  }
  if (diff.inDays >= 2) {
    return l10n.daysAgo(diff.inDays);
  }
  if (diff.inDays == 1) return '1d';
  if (diff.inHours >= 2) return '${diff.inHours}h';
  if (diff.inMinutes >= 2) return '${diff.inMinutes}m';
  return 'now';
}

class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.radius = 16,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surfaceContainerHigh;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        final dx = lerpDouble(-1, 2, t)!;
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(dx - 1, 0),
              end: Alignment(dx + 1, 0),
              colors: [
                base,
                Color.lerp(base, highlight, 0.65)!,
                base,
              ],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }
}

class AppCardListSkeleton extends StatelessWidget {
  const AppCardListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppSkeletonBox(height: 18, width: 220),
                SizedBox(height: 10),
                AppSkeletonBox(height: 14, width: double.infinity),
                SizedBox(height: 8),
                AppSkeletonBox(height: 14, width: 240),
                SizedBox(height: 12),
                Row(
                  children: [
                    AppSkeletonBox(height: 24, width: 86, radius: 999),
                    SizedBox(width: 8),
                    AppSkeletonBox(height: 24, width: 76, radius: 999),
                    SizedBox(width: 8),
                    AppSkeletonBox(height: 24, width: 96, radius: 999),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppThemeModeButton extends ConsumerWidget {
  const AppThemeModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeControllerProvider);
    final effective = ref.read(themeModeControllerProvider.notifier).effectiveBrightness;
    final isDark = effective == Brightness.dark;

    return IconButton(
      onPressed: () => ref.read(themeModeControllerProvider.notifier).toggle(),
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      tooltip: isDark ? 'Light mode' : 'Dark mode',
    );
  }
}

class CityOption {
  const CityOption({
    required this.key,
    required this.name,
    required this.nameAr,
    required this.region,
    required this.regionAr,
    required this.isMajor,
  });

  final String key;
  final String name;
  final String nameAr;
  final String region;
  final String regionAr;
  final bool isMajor;

  factory CityOption.fromJson(Map<String, dynamic> json) {
    return CityOption(
      key: (json['key'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? '').toString(),
      region: (json['region'] ?? '').toString(),
      regionAr: (json['region_ar'] ?? '').toString(),
      isMajor: json['is_major'] == true || json['is_major'] == 1,
    );
  }
}

final cityOptionsProvider = FutureProvider<List<CityOption>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final json = await client.getJson<Map<String, dynamic>>('cities/all');
  final data = json['data'];
  if (data is List) {
    return data.whereType<Map>().map((e) => CityOption.fromJson(e.cast<String, dynamic>())).toList();
  }
  return const [];
});

class AppCityPickerField extends ConsumerWidget {
  const AppCityPickerField({
    super.key,
    required this.controller,
    required this.labelText,
    this.errorText,
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String labelText;
  final String? errorText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: const Icon(Icons.location_city_outlined),
        suffixIcon: const Icon(Icons.expand_more),
        errorText: errorText,
      ),
      validator: validator,
      onTap: () => _open(context, ref),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final cities = await ref.read(cityOptionsProvider.future);
    if (!context.mounted) return;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final selected = await showModalBottomSheet<CityOption>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final height = MediaQuery.sizeOf(context).height;
        final sheetHeight = height * 0.72;
        var query = '';

        return StatefulBuilder(
          builder: (context, setState) {
            final q = query.trim().toLowerCase();
            final filtered = q.isEmpty
                ? cities
                : cities
                    .where((c) {
                      final name = (isArabic ? c.nameAr : c.name).toLowerCase();
                      final region = (isArabic ? c.regionAr : c.region).toLowerCase();
                      return name.contains(q) || region.contains(q);
                    })
                    .toList(growable: false);

            return SafeArea(
              child: SizedBox(
                height: sheetHeight,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                      child: TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: context.l10n.searchCity,
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (v) => setState(() => query = v),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          final title = isArabic ? c.nameAr : c.name;
                          final subtitle = isArabic ? c.regionAr : c.region;
                          return ListTile(
                            title: Text(title),
                            subtitle: subtitle.trim().isEmpty ? null : Text(subtitle),
                            trailing: c.isMajor ? const Icon(Icons.star_outline) : null,
                            onTap: () => Navigator.pop(context, c),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected == null) return;
    controller.text = (isArabic ? selected.nameAr : selected.name).trim();
  }
}
