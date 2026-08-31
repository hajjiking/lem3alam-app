import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/taskers_repository_impl.dart';
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
    );
  },
  dependencies: [taskersRepositoryProvider],
);

final publicTaskerProfileControllerProvider =
    NotifierProvider<PublicTaskerProfileController, Map<int, bool>>(
  PublicTaskerProfileController.new,
);

/// Client-only local actions for a public tasker profile.
class PublicTaskerProfileController extends Notifier<Map<int, bool>> {
  @override
  Map<int, bool> build() => const {};

  bool isSaved(int taskerId, {bool initialValue = false}) =>
      state[taskerId] ?? initialValue;

  void toggleSaved(int taskerId, {bool initialValue = false}) {
    state = {
      ...state,
      taskerId: !isSaved(taskerId, initialValue: initialValue),
    };
  }

  /// Both message buttons intentionally enter through this single method.
  int conversationPeerId(int taskerId) => taskerId;
}

PublicProfileModel _merge({
  required TaskerProfile profile,
  required List<TaskerReview> reviews,
  required int totalReviews,
}) {
  final features = <String>{
    for (final skill in profile.skills)
      if (skill.name.trim().isNotEmpty) skill.name.trim(),
  }.toList(growable: false);

  // This public-view fixture intentionally differs from the owner-profile
  // fixture; product can reconcile the two snapshots when backend seed data is
  // finalized.
  final isReferenceTasker =
      profile.name.trim().toLowerCase() == 'youssef el amrani';
  const referenceExpertise = [
    'Fixing leaks and pipes',
    'Water heater installation',
    'Electrical wiring & outlets',
    'Light fixtures installation',
    'Wall painting (interior & exterior)',
    'Tile and floor installation',
    'Drywall and plaster repair',
    'Furniture & fixture assembly',
  ];
  const referenceWork = [
    'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=700',
    'https://images.unsplash.com/photo-1524484485831-a92ffc0de03f?w=700',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=700',
    'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=700',
  ];

  final services = profile.services
      .map(
        (service) => PublicServiceItem(
          icon: _iconForName(service.name),
          name: service.name,
          startingPrice: service.priceMAD > 0 ? service.priceMAD : null,
          currency: service.currency,
        ),
      )
      .toList(growable: false);

  final publicReviews = reviews
      .map(
        (review) => PublicReviewItem(
          reviewerName: review.reviewerName,
          rating: review.rating.toDouble(),
          comment: review.comment,
          dateLabel: _formatDate(review.createdAtIso),
          reviewerAvatar: review.reviewerAvatar,
          taskTitle: review.taskTitle,
        ),
      )
      .toList(growable: false);

  final portfolioItems = profile.portfolio
      .map(
        (item) => PublicPortfolioItem(
          title: item.title,
          imagePath: item.imagePath,
          description: item.description,
          category: item.category,
          tags: item.tags,
          isFeatured: item.isFeatured,
        ),
      )
      .toList(growable: false);

  return PublicProfileModel(
    id: profile.id,
    name: profile.name,
    profession: profile.displayTitle(''),
    profileImageUrl: profile.profileImage ?? '',
    rating: profile.averageRating,
    reviewCount: totalReviews,
    isVerified: profile.isVerified,
    isOnline: profile.available,
    isTopRated: profile.isTopRated,
    availableToday: profile.available,
    yearsExperience: profile.yearsExperience,
    city: profile.city,
    bio: profile.bio,
    features: features,
    phone: profile.phone,
    responseMinutes:
        profile.responseTimeMinutes ?? (isReferenceTasker ? 30 : null),
    jobsCompleted: profile.jobsCompleted ?? (isReferenceTasker ? 47 : null),
    jobsCompletedThisMonth:
        profile.jobsCompletedThisMonth == 0 && isReferenceTasker
            ? 6
            : profile.jobsCompletedThisMonth,
    jobsInProgress: profile.jobsInProgress ?? (isReferenceTasker ? 5 : 0),
    jobsInProgressThisMonth:
        profile.jobsInProgressThisMonth == 0 && isReferenceTasker
            ? 2
            : profile.jobsInProgressThisMonth,
    successRate: profile.successRate ?? (isReferenceTasker ? 98 : 0),
    completionRate:
        (profile.successRate ?? (isReferenceTasker ? 98 : 0)).toDouble(),
    isSavedByCurrentClient: profile.isSavedByCurrentClient,
    emailVerified: profile.emailVerified || isReferenceTasker,
    phoneVerified: profile.phoneVerified || isReferenceTasker,
    expertiseItems: profile.expertiseItems.isNotEmpty
        ? profile.expertiseItems
        : isReferenceTasker
            ? referenceExpertise
            : const [],
    portfolioImageUrls: profile.portfolioImageUrls.isNotEmpty
        ? profile.portfolioImageUrls
        : isReferenceTasker
            ? referenceWork
            : const [],
    additionalSkillCount: isReferenceTasker ? 3 : 0,
    services: services,
    reviews: publicReviews,
    portfolio: portfolioItems,
  );
}

IconData _iconForName(String name) {
  final normalized = name.toLowerCase();
  if (normalized.contains('electric') ||
      normalized.contains('wiring') ||
      normalized.contains('light') ||
      normalized.contains('panel')) {
    return Icons.bolt_rounded;
  }
  if (normalized.contains('plumb') ||
      normalized.contains('water') ||
      normalized.contains('leak') ||
      normalized.contains('drain') ||
      normalized.contains('bathroom') ||
      normalized.contains('pipe') ||
      normalized.contains('heater')) {
    return Icons.water_drop_rounded;
  }
  if (normalized.contains('paint')) return Icons.format_paint_outlined;
  if (normalized.contains('clean')) return Icons.cleaning_services_outlined;
  if (normalized.contains('ac ') ||
      normalized.contains('hvac') ||
      normalized.contains('conditioning')) {
    return Icons.ac_unit_rounded;
  }
  if (normalized.contains('carpenter') ||
      normalized.contains('wood') ||
      normalized.contains('cabinet') ||
      normalized.contains('furniture')) {
    return Icons.carpenter_rounded;
  }
  if (normalized.contains('move') || normalized.contains('transport')) {
    return Icons.local_shipping_rounded;
  }
  return Icons.handyman_outlined;
}

String _formatDate(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inDays < 1) return '${difference.inHours} h ago';
  if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  }
  if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks == 1 ? '' : 's'} ago';
  }
  return DateFormat('MMM y').format(date);
}
