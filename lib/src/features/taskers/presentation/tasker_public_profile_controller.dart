import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/taskers_repository_impl.dart';
import '../domain/mock/mock_public_profile.dart';
import '../domain/public_profile_model.dart';
import '../domain/tasker_profile.dart';
import '../domain/tasker_review.dart';
import '../domain/taskers_repository.dart';

final publicTaskerProfileProvider =
    FutureProvider.autoDispose.family<PublicProfileModel, int>(
  (ref, id) async {
    final repo = ref.watch(taskersRepositoryProvider);
    final profile = await repo.getProfile(id);
    final reviewsPage = await repo.reviews(
      taskerId: id,
      page: 1,
      perPage: 10,
      query: const TaskerReviewsQuery(sort: 'newest'),
    );
    return _merge(
      profile: profile,
      reviews: reviewsPage.items,
      totalReviews: profile.totalReviews,
      distribution: profile.ratingDistribution,
    );
  },
  dependencies: [taskersRepositoryProvider],
);

final publicTaskerProfileFallbackProvider =
    Provider.autoDispose.family<PublicProfileModel, int>(
  (ref, id) => mockPublicProfileById(id),
  name: 'publicTaskerProfileFallbackProvider',
);

PublicProfileModel _merge({
  required TaskerProfile profile,
  required List<TaskerReview> reviews,
  required int totalReviews,
  required Map<int, int> distribution,
}) {
  final rnd = Random(profile.id * 31 + 7);
  final features = <String>{
    for (final s in profile.skills) s.category ?? s.name,
  }
    ..add('On Time')
    ..add('Affordable');
  if (profile.isVerified) features.add('Certified');

  final profTitle = profile.professionalTitle?.trim().isNotEmpty == true
      ? profile.professionalTitle!
      : profile.displayTitle('Handyman');

  final avail = <DateTime>[];
  final unavail = <DateTime>[];
  final startOffset = profile.id % 3;
  final today = DateTime.now();
  for (var i = 0; i < 7; i++) {
    if (i == 3 || i == 6) {
      unavail.add(DateTime(
        today.year,
        today.month,
        today.day + startOffset + i,
      ));
    } else {
      avail.add(DateTime(
        today.year,
        today.month,
        today.day + startOffset + i,
      ));
    }
  }

  final services = profile.services.isNotEmpty
      ? profile.services
          .map(
            (s) => PublicServiceItem(
              icon: _iconForName(s.name),
              name: s.name,
              startingPrice: s.priceMAD,
              currency: s.currency,
              estimatedDuration: _estimateDuration(s.priceMAD),
              color: _pickColorForName(s.name, rnd),
            ),
          )
          .toList(growable: false)
      : _defaultServices(profTitle, rnd);

  final publicReviews = reviews
      .map(
        (r) => PublicReviewItem(
          reviewerName: r.reviewerName.isEmpty ? 'Customer' : r.reviewerName,
          rating: r.rating.toDouble(),
          comment: r.comment,
          dateLabel: _formatDate(r.createdAtIso),
          reviewerAvatar: r.reviewerAvatar,
          verifiedCustomer: true,
          taskTitle: r.taskTitle,
        ),
      )
      .toList(growable: false);

  final portfolioItems = profile.portfolio
      .map(
        (p) => PublicPortfolioItem(
          title: p.title,
          imagePath: p.imagePath,
          description: p.description,
          category: p.category,
          tags: p.tags,
          isFeatured: p.isFeatured,
        ),
      )
      .toList(growable: false);

  return PublicProfileModel(
    id: profile.id,
    name: profile.name,
    profession: profTitle,
    profileImageUrl: profile.profileImage ?? '',
    rating: profile.averageRating,
    reviewCount: totalReviews,
    isVerified: profile.isVerified,
    isOnline: profile.available,
    isTopRated: profile.isTopRated,
    availableToday: profile.available,
    yearsExperience: profile.yearsExperience,
    city: profile.city,
    country: 'Morocco',
    distanceKm: profile.id == 0 ? null : _distFromId(profile.id),
    bio: profile.bio,
    features: features.take(4).toList(growable: false),
    phone: profile.phone,
    responseMinutes: 12 + (profile.id * 5) % 60,
    jobsCompleted: 80 + (profile.id * 13) % 500,
    completionRate: double.parse(((90 + (profile.id % 10)) / 100).toStringAsFixed(2)),
    services: services,
    reviews: publicReviews,
    portfolio: portfolioItems,
    availabilityDates: avail,
    unavailableDates: unavail,
  );
}

List<PublicServiceItem> _defaultServices(String title, Random rnd) {
  final t = title.toLowerCase();
  if (t.contains('electric') || t.contains('كهرب') || t.contains('كهربائي')) {
    return [
      PublicServiceItem(
        icon: Icons.bolt_rounded,
        name: 'Electrical Installation',
        startingPrice: 120,
        currency: 'MAD',
        estimatedDuration: '90 minutes',
        color: const Color(0xFF2563EB),
      ),
      PublicServiceItem(
        icon: Icons.handyman_outlined,
        name: 'Electrical Repair',
        startingPrice: 80,
        currency: 'MAD',
        estimatedDuration: '60 minutes',
        color: const Color(0xFFF59E0B),
      ),
    ];
  }
  if (t.contains('plumb') || t.contains('سباك')) {
    return [
      PublicServiceItem(
        icon: Icons.water_drop_rounded,
        name: 'Leak Detection & Repair',
        startingPrice: 90,
        currency: 'MAD',
        estimatedDuration: '60 minutes',
        color: const Color(0xFF0EA5E9),
      ),
      PublicServiceItem(
        icon: Icons.handyman_outlined,
        name: 'Drain Cleaning',
        startingPrice: 110,
        currency: 'MAD',
        estimatedDuration: '45 minutes',
        color: const Color(0xFFF59E0B),
      ),
    ];
  }
  if (t.contains('paint') || t.contains('دهان') || t.contains('نقاش')) {
    return [
      PublicServiceItem(
        icon: Icons.format_paint_outlined,
        name: 'Interior Painting',
        startingPrice: 25,
        currency: 'MAD/m²',
        estimatedDuration: 'per room',
        color: const Color(0xFFF59E0B),
      ),
      PublicServiceItem(
        icon: Icons.format_paint_outlined,
        name: 'Exterior Painting',
        startingPrice: 35,
        currency: 'MAD/m²',
        estimatedDuration: '1-3 days',
        color: const Color(0xFF10B981),
      ),
    ];
  }
  return [
    PublicServiceItem(
      icon: Icons.handyman_outlined,
      name: 'General Repairs',
      startingPrice: 70 + rnd.nextInt(80),
      currency: 'MAD',
      estimatedDuration: '60 minutes',
      color: const Color(0xFF2563EB),
    ),
    PublicServiceItem(
      icon: Icons.construction_rounded,
      name: 'Furniture Assembly',
      startingPrice: 45 + rnd.nextInt(50),
      currency: 'MAD',
      estimatedDuration: '45 minutes',
      color: const Color(0xFF10B981),
    ),
  ];
}

String _estimateDuration(int price) {
  if (price <= 0) return '—';
  if (price < 60) return '45 minutes';
  if (price < 120) return '60 minutes';
  if (price < 200) return '90 minutes';
  if (price < 400) return '120 minutes';
  return '3-4 hours';
}

IconData _iconForName(String name) {
  final n = name.toLowerCase();
  if (n.contains('electric') || n.contains('wiring') || n.contains('light') || n.contains('panel')) {
    return Icons.bolt_rounded;
  }
  if (n.contains('plumb') ||
      n.contains('water') ||
      n.contains('leak') ||
      n.contains('drain') ||
      n.contains('bathroom') ||
      n.contains('pipe') ||
      n.contains('heater')) {
    return Icons.water_drop_rounded;
  }
  if (n.contains('paint')) return Icons.format_paint_outlined;
  if (n.contains('clean')) return Icons.cleaning_services_outlined;
  if (n.contains('ac ') ||
      n.contains('hvac') ||
      n.contains('conditioning') ||
      n.contains('climate') ||
      n.contains('cool') ||
      n.contains('heat')) {
    return Icons.ac_unit_rounded;
  }
  if (n.contains('carpenter') ||
      n.contains('wood') ||
      n.contains('door') ||
      n.contains('cabinet') ||
      n.contains('furnitur') ||
      n.contains('shelf') ||
      n.contains('bookshelf')) {
    return Icons.carpenter_rounded;
  }
  if (n.contains('move') || n.contains('transport')) return Icons.local_shipping_rounded;
  if (n.contains('repair') || n.contains('fix') || n.contains('handyman') || n.contains('install')) {
    return Icons.handyman_outlined;
  }
  return Icons.construction_rounded;
}

Color _pickColorForName(String name, Random rnd) {
  final palette = const [
    Color(0xFF2563EB),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF0EA5E9),
    Color(0xFFEF4444),
    Color(0xFF7C3AED),
  ];
  if (name.contains('Electric') || name.contains('Wiring')) return palette[0];
  if (name.contains('Paint')) return palette[2];
  if (name.contains('Plumb') || name.contains('Leak') || name.contains('Water') || name.contains('Drain')) {
    return palette[3];
  }
  if (name.contains('Clean')) return palette[1];
  return palette[rnd.nextInt(palette.length)];
}

double _distFromId(int id) {
  return double.parse(((id % 9) * 0.6 + 0.8).toStringAsFixed(1));
}

String _formatDate(String iso) {
  try {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return '$w week${w == 1 ? '' : 's'} ago';
    }
    return DateFormat('MMM y').format(d);
  } catch (_) {
    return '';
  }
}
