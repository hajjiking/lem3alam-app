class TaskerProfile {
  const TaskerProfile({
    required this.id,
    required this.name,
    this.professionalTitle,
    this.city,
    this.address,
    this.bio,
    this.phone,
    this.profileImage,
    this.coverImage,
    this.hourlyRate,
    required this.available,
    required this.isVerified,
    this.yearsExperience,
    this.createdAt,
    this.isTopRated = false,
    required this.averageRating,
    required this.totalReviews,
    this.ratingDistribution = const {},
    this.skills = const [],
    this.services = const [],
    this.portfolio = const [],
    this.socialAccounts = const [],
    this.responseTimeMinutes,
    this.isSavedByCurrentClient = false,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.expertiseItems = const [],
    this.portfolioImageUrls = const [],
    this.jobsCompleted,
    this.jobsCompletedThisMonth = 0,
    this.jobsInProgress,
    this.jobsInProgressThisMonth = 0,
    this.successRate,
  });

  final int id;
  final String name;
  final String? professionalTitle;
  final String? city;
  final String? address;
  final String? bio;
  final String? phone;
  final String? profileImage;
  final String? coverImage;
  final double? hourlyRate;
  final bool available;
  final bool isVerified;
  final int? yearsExperience;
  final DateTime? createdAt;
  final bool isTopRated;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final List<TaskerSkill> skills;
  final List<TaskerService> services;
  final List<TaskerPortfolioItem> portfolio;
  final List<TaskerSocialAccount> socialAccounts;
  final int? responseTimeMinutes;
  final bool isSavedByCurrentClient;
  final bool emailVerified;
  final bool phoneVerified;
  final List<String> expertiseItems;
  final List<String> portfolioImageUrls;
  final int? jobsCompleted;
  final int jobsCompletedThisMonth;
  final int? jobsInProgress;
  final int jobsInProgressThisMonth;
  final int? successRate;

  String displayTitle(String fallback) {
    final t = (professionalTitle ?? '').trim();
    if (t.isNotEmpty) return t;
    if (skills.isNotEmpty) return skills.first.name;
    return fallback;
  }

  factory TaskerProfile.fromJson(Map<String, dynamic> json) {
    final skillsRaw = json['skills'];
    final servicesRaw = json['services'];
    final portfolioRaw = json['portfolio'];
    final socialsRaw = json['social_accounts'];
    final ratingDistRaw = json['rating_distribution'];

    final skills = <TaskerSkill>[];
    if (skillsRaw is List) {
      for (final v in skillsRaw) {
        if (v is Map<String, dynamic>) skills.add(TaskerSkill.fromJson(v));
      }
    }

    final services = <TaskerService>[];
    if (servicesRaw is List) {
      for (final v in servicesRaw) {
        if (v is Map<String, dynamic>) services.add(TaskerService.fromJson(v));
      }
    }

    final portfolio = <TaskerPortfolioItem>[];
    if (portfolioRaw is List) {
      for (final v in portfolioRaw) {
        if (v is Map<String, dynamic>) {
          portfolio.add(TaskerPortfolioItem.fromJson(v));
        }
      }
    }

    final socials = <TaskerSocialAccount>[];
    if (socialsRaw is List) {
      for (final v in socialsRaw) {
        if (v is Map<String, dynamic>) {
          socials.add(TaskerSocialAccount.fromJson(v));
        }
      }
    }

    final ratingDistribution = <int, int>{};
    if (ratingDistRaw is Map) {
      for (final e in ratingDistRaw.entries) {
        final k = int.tryParse(e.key.toString());
        final v = _intOptional(e.value);
        if (k != null && v != null && k >= 1 && k <= 5) {
          ratingDistribution[k] = v;
        }
      }
    }

    return TaskerProfile(
      id: _intRequired(json['id']),
      name: (json['name'] ?? '').toString(),
      professionalTitle:
          json['professional_title']?.toString() ?? json['title']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      bio: json['bio']?.toString(),
      phone: json['phone']?.toString(),
      profileImage: json['profile_image']?.toString(),
      coverImage: json['cover_image']?.toString() ?? json['cover']?.toString(),
      hourlyRate: _doubleOptional(json['hourly_rate']),
      available: json['available'] == true || json['available'] == 1,
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      yearsExperience: _intOptional(json['years_experience']) ??
          _intOptional(json['experience_years']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      isTopRated: json['is_top_rated'] == true ||
          json['is_top_rated'] == 1 ||
          json['top_rated'] == true ||
          json['top_rated'] == 1,
      averageRating: _doubleOptional(json['average_rating']) ?? 0,
      totalReviews: _intOptional(json['total_reviews']) ?? 0,
      ratingDistribution: ratingDistribution,
      skills: skills,
      services: services,
      portfolio: portfolio,
      socialAccounts: socials,
      responseTimeMinutes: _intOptional(json['response_time_minutes']) ??
          _intOptional(json['response_minutes']),
      isSavedByCurrentClient: json['is_saved_by_current_client'] == true ||
          json['is_saved_by_current_client'] == 1,
      emailVerified:
          json['email_verified'] == true || json['email_verified'] == 1,
      phoneVerified:
          json['phone_verified'] == true || json['phone_verified'] == 1,
      expertiseItems: _stringList(json['expertise_items']),
      portfolioImageUrls: _stringList(json['portfolio_image_urls']),
      jobsCompleted: _intOptional(json['jobs_completed']),
      jobsCompletedThisMonth:
          _intOptional(json['jobs_completed_this_month']) ?? 0,
      jobsInProgress: _intOptional(json['jobs_in_progress']),
      jobsInProgressThisMonth:
          _intOptional(json['jobs_in_progress_this_month']) ?? 0,
      successRate: _intOptional(json['success_rate']),
    );
  }
}

class TaskerService {
  const TaskerService({
    required this.name,
    required this.priceMAD,
    this.currency = 'MAD',
  });

  final String name;
  final int priceMAD;
  final String currency;

  factory TaskerService.fromJson(Map<String, dynamic> json) {
    final price = _intOptional(json['price']) ??
        _intOptional(json['price_mad']) ??
        _doubleOptional(json['price'])?.toInt() ??
        0;
    return TaskerService(
      name: (json['name'] ?? '').toString(),
      priceMAD: price,
      currency: (json['currency'] ?? 'MAD').toString(),
    );
  }
}

class TaskerSkill {
  const TaskerSkill({
    required this.id,
    required this.name,
    this.category,
    this.experienceLevel,
    this.yearsExperience,
    this.description,
    required this.isVerified,
  });

  final int id;
  final String name;
  final String? category;
  final String? experienceLevel;
  final int? yearsExperience;
  final String? description;
  final bool isVerified;

  factory TaskerSkill.fromJson(Map<String, dynamic> json) {
    return TaskerSkill(
      id: _intRequired(json['id']),
      name: (json['name'] ?? '').toString(),
      category: json['category']?.toString(),
      experienceLevel: json['experience_level']?.toString(),
      yearsExperience: _intOptional(json['years_experience']),
      description: json['description']?.toString(),
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
    );
  }
}

class TaskerPortfolioItem {
  const TaskerPortfolioItem({
    required this.id,
    required this.title,
    this.description,
    required this.imagePath,
    this.imageAlt,
    this.category,
    this.tags = const [],
    required this.isFeatured,
  });

  final int id;
  final String title;
  final String? description;
  final String imagePath;
  final String? imageAlt;
  final String? category;
  final List<String> tags;
  final bool isFeatured;

  factory TaskerPortfolioItem.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    final tags = <String>[];
    if (tagsRaw is List) {
      for (final v in tagsRaw) {
        if (v == null) continue;
        final s = v.toString();
        if (s.isNotEmpty) tags.add(s);
      }
    }

    return TaskerPortfolioItem(
      id: _intRequired(json['id']),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      imagePath: (json['image_path'] ?? '').toString(),
      imageAlt: json['image_alt']?.toString(),
      category: json['category']?.toString(),
      tags: tags,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
    );
  }
}

class TaskerSocialAccount {
  const TaskerSocialAccount({
    required this.provider,
    this.name,
    this.email,
  });

  final String provider;
  final String? name;
  final String? email;

  factory TaskerSocialAccount.fromJson(Map<String, dynamic> json) {
    return TaskerSocialAccount(
      provider: (json['provider'] ?? '').toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

int _intRequired(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value == null) return 0;
  return int.tryParse(value.toString()) ?? 0;
}

int? _intOptional(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final s = value.toString();
  if (s.isEmpty) return null;
  return int.tryParse(s);
}

double? _doubleOptional(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
