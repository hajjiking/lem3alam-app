import 'package:flutter/material.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/l10n.dart';
import 'badge_chip.dart';
import 'rating_widget.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviewCount,
    this.city,
    this.country,
    this.distanceKm,
    this.isVerified = false,
    this.isOnline = false,
    this.isTopRated = false,
    this.yearsExperience,
    this.availableToday = false,
    this.onMessage,
    this.onBookNow,
    this.heroTag,
    this.customBadges = const [],
    this.messageLabel = 'Message',
    this.bookNowLabel = 'Book Now',
  });

  final String? profileImageUrl;
  final String name;
  final String profession;
  final double rating;
  final int reviewCount;
  final String? city;
  final String? country;
  final double? distanceKm;
  final bool isVerified;
  final bool isOnline;
  final bool isTopRated;
  final int? yearsExperience;
  final bool availableToday;
  final VoidCallback? onMessage;
  final VoidCallback? onBookNow;
  final Object? heroTag;
  final List<Widget> customBadges;
  final String messageLabel;
  final String bookNowLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasLocation =
        (city ?? '').trim().isNotEmpty || (country ?? '').trim().isNotEmpty;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(
              imageUrl: profileImageUrl,
              heroTag: heroTag,
              isVerified: isVerified,
              isOnline: isOnline,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            fontSize: 24,
                            color: scheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profession,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        RatingWidget(rating: rating),
                        const SizedBox(width: 8),
                        Text(
                          rating.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurface,
                                  ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '($reviewCount)',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    if (hasLocation) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              [city, country]
                                  .where((x) => (x ?? '').trim().isNotEmpty)
                                  .join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (distanceKm != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.directions_walk_outlined,
                            size: 15,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${distanceKm!.toStringAsFixed(1)} km away',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (isVerified) BadgeChip.verified(context, l10n.verifiedIdentity),
            if (isTopRated) BadgeChip.topRated(context, l10n.topRated),
            if (yearsExperience != null && yearsExperience! > 0)
              BadgeChip.experience(
                  context, l10n.verifiedYears(yearsExperience!)),
            if (availableToday)
              BadgeChip.availableToday(context, l10n.availableTodayHint),
            ...customBadges,
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onMessage,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppStyle.controlHeight),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  side: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.6),
                      width: 1.2),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                label: Text(
                  messageLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: onBookNow,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppStyle.controlHeight),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                icon: const Icon(Icons.calendar_month_rounded, size: 20),
                label: Text(
                  bookNowLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, letterSpacing: 0.1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.imageUrl,
    required this.heroTag,
    required this.isVerified,
    required this.isOnline,
  });

  final String? imageUrl;
  final Object? heroTag;
  final bool isVerified;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolved = imageUrl == null ? null : _resolveUrl(imageUrl!);
    final avatar = ClipOval(
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        width: 110,
        height: 110,
        child: resolved == null
            ? Icon(Icons.person_outline_rounded,
                size: 52, color: scheme.onSurfaceVariant)
            : Image.network(
                resolved,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.person_outline_rounded,
                    size: 52, color: scheme.onSurfaceVariant),
              ),
      ),
    );

    final withRing = Container(
      width: 110,
      height: 110,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: avatar,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        heroTag == null ? withRing : Hero(tag: heroTag!, child: withRing),
        if (isVerified)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.surface, width: 2),
              ),
              child: Icon(Icons.check_rounded,
                  size: 16, color: context.appColors.onPrimary),
            ),
          ),
        if (isOnline)
          Positioned(
            right: 2,
            top: 6,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: context.appTokens.success,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.surface, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: context.appTokens.success.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static String? _resolveUrl(String path) {
    final p = path.trim();
    if (p.isEmpty) return null;
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    final api = Uri.parse(AppConfig.apiBaseUrl);
    final publicBase = api
        .replace(path: api.path.replaceAll(RegExp(r'/api/v1/?$'), ''))
        .toString()
        .replaceAll(RegExp(r'/$'), '');
    final normalized = p.startsWith('/') ? p.substring(1) : p;
    return '$publicBase/storage/$normalized';
  }
}
