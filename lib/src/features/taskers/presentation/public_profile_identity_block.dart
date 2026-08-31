import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/public_profile_model.dart';

class PublicProfileIdentityBlock extends StatelessWidget {
  const PublicProfileIdentityBlock({
    super.key,
    required this.profile,
    required this.saved,
    required this.onMessage,
    required this.onToggleSaved,
  });

  final PublicProfileModel profile;
  final bool saved;
  final VoidCallback onMessage;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 620;
      final identity = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(profile: profile, compact: compact),
          const SizedBox(width: 18),
          Expanded(child: _Details(profile: profile)),
        ],
      );
      final actions = _Actions(
        saved: saved,
        onMessage: onMessage,
        onToggleSaved: onToggleSaved,
      );
      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [identity, const SizedBox(height: 18), actions],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: identity),
          const SizedBox(width: 24),
          actions
        ],
      );
    });
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile, required this.compact});
  final PublicProfileModel profile;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 104.0 : 132.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .18),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: profile.profileImageUrl.trim().isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 58)
                : Image.network(
                    profile.profileImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, color: Colors.white, size: 58),
                  ),
          ),
          if (profile.isOnline)
            PositionedDirectional(
              end: 2,
              bottom: 6,
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: const Color(0xFF21C87A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.profile});
  final PublicProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final location = [profile.city, profile.country]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join(', ');
    return DefaultTextStyle.merge(
      style: const TextStyle(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 7,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(profile.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w900)),
              if (profile.isVerified)
                const Icon(Icons.verified, color: Color(0xFF73B6FF), size: 23),
            ],
          ),
          if (profile.profession.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(profile.profession,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
          if (location.isNotEmpty) ...[
            const SizedBox(height: 7),
            _Info(icon: Icons.location_on_outlined, text: location),
          ],
          if (profile.responseMinutes != null) ...[
            const SizedBox(height: 5),
            _Info(
              icon: Icons.schedule_outlined,
              text: l10n.publicProfileRespondsWithin(
                  profile.responseMinutes.toString()),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFFFFC107), size: 22),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${profile.rating.toStringAsFixed(1)} (${l10n.profileBadgeReviewCaption(profile.reviewCount.toString())})',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 7),
          Flexible(child: Text(text)),
        ],
      );
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.saved,
    required this.onMessage,
    required this.onToggleSaved,
  });
  final bool saved;
  final VoidCallback onMessage;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white70),
          ),
          onPressed: onMessage,
          icon: const Icon(Icons.chat_bubble_outline, size: 20),
          label: Text(l10n.publicProfileMessage),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          onPressed: onToggleSaved,
          icon: Icon(saved ? Icons.favorite : Icons.favorite_border),
          label: Text(saved ? l10n.publicProfileSaved : l10n.publicProfileSave),
        ),
      ],
    );
  }
}
