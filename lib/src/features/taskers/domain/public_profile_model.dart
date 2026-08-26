import 'package:flutter/material.dart';

class PublicProfileModel {
  const PublicProfileModel({
    required this.id,
    required this.name,
    required this.profession,
    required this.profileImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.isOnline,
    required this.isTopRated,
    required this.availableToday,
    required this.yearsExperience,
    this.city,
    this.country,
    this.distanceKm,
    this.bio,
    this.features = const [],
    this.phone,
    this.responseMinutes,
    this.jobsCompleted,
    this.completionRate,
    this.services = const [],
    this.reviews = const [],
    this.portfolio = const [],
    this.availabilityDates = const [],
    this.unavailableDates = const [],
  });

  factory PublicProfileModel.fromJson(Map<String, dynamic> json) {
    final servicesRaw = json['services'] as List?;
    final reviewsRaw = json['reviews'] as List?;
    final portfolioRaw = json['portfolio'] as List?;
    final featuresRaw = json['features'] as List?;
    final availRaw = json['availability_dates'] as List?;
    final unavailRaw = json['unavailable_dates'] as List?;

    final services = <PublicServiceItem>[];
    if (servicesRaw != null) {
      for (final s in servicesRaw) {
        if (s is Map<String, dynamic>) services.add(PublicServiceItem.fromJson(s));
      }
    }

    final reviews = <PublicReviewItem>[];
    if (reviewsRaw != null) {
      for (final r in reviewsRaw) {
        if (r is Map<String, dynamic>) reviews.add(PublicReviewItem.fromJson(r));
      }
    }

    final portfolio = <PublicPortfolioItem>[];
    if (portfolioRaw != null) {
      for (final p in portfolioRaw) {
        if (p is Map<String, dynamic>) portfolio.add(PublicPortfolioItem.fromJson(p));
      }
    }

    final features = <String>[];
    if (featuresRaw != null) {
      for (final f in featuresRaw) {
        final s = f?.toString();
        if (s != null && s.trim().isNotEmpty) features.add(s.trim());
      }
    }

    final av = <DateTime>[];
    if (availRaw != null) {
      for (final a in availRaw) {
        final d = DateTime.tryParse(a?.toString() ?? '');
        if (d != null) av.add(DateTime(d.year, d.month, d.day));
      }
    }

    final un = <DateTime>[];
    if (unavailRaw != null) {
      for (final a in unavailRaw) {
        final d = DateTime.tryParse(a?.toString() ?? '');
        if (d != null) un.add(DateTime(d.year, d.month, d.day));
      }
    }

    return PublicProfileModel(
      id: _int(json['id']) ?? 0,
      name: (json['name'] ?? '').toString(),
      profession: (json['profession'] ?? '').toString(),
      profileImageUrl: (json['profile_image_url'] ?? '').toString(),
      rating: _double(json['rating']) ?? 0,
      reviewCount: _int(json['review_count']) ?? 0,
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      isOnline: json['is_online'] == true || json['is_online'] == 1,
      isTopRated: json['is_top_rated'] == true || json['is_top_rated'] == 1,
      availableToday: json['available_today'] == true || json['available_today'] == 1,
      yearsExperience: _int(json['years_experience']),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      distanceKm: _double(json['distance_km']),
      bio: json['bio']?.toString(),
      features: features,
      phone: json['phone']?.toString(),
      responseMinutes: _int(json['response_minutes']),
      jobsCompleted: _int(json['jobs_completed']),
      completionRate: _double(json['completion_rate']),
      services: services,
      reviews: reviews,
      portfolio: portfolio,
      availabilityDates: av,
      unavailableDates: un,
    );
  }

  final int id;
  final String name;
  final String profession;
  final String profileImageUrl;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isOnline;
  final bool isTopRated;
  final bool availableToday;
  final int? yearsExperience;
  final String? city;
  final String? country;
  final double? distanceKm;
  final String? bio;
  final List<String> features;
  final String? phone;
  final int? responseMinutes;
  final int? jobsCompleted;
  final double? completionRate;
  final List<PublicServiceItem> services;
  final List<PublicReviewItem> reviews;
  final List<PublicPortfolioItem> portfolio;
  final List<DateTime> availabilityDates;
  final List<DateTime> unavailableDates;

  static int? _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v == null) return null;
    return int.tryParse(v.toString());
  }

  static double? _double(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v == null) return null;
    return double.tryParse(v.toString());
  }
}

class PublicServiceItem {
  const PublicServiceItem({
    required this.icon,
    required this.name,
    this.startingPrice,
    this.currency = 'MAD',
    this.estimatedDuration,
    this.color,
  });

  factory PublicServiceItem.fromJson(Map<String, dynamic> json) {
    final c = json['color']?.toString();
    Color? parsed;
    if (c != null && c.startsWith('#') && (c.length == 7 || c.length == 9)) {
      var hex = c.substring(1);
      if (hex.length == 6) hex = 'FF$hex';
      final v = int.tryParse(hex, radix: 16);
      if (v != null) parsed = Color(v);
    }
    return PublicServiceItem(
      icon: _icon(json['icon']),
      name: (json['name'] ?? '').toString(),
      startingPrice: _int(json['starting_price']),
      currency: (json['currency'] ?? 'MAD').toString(),
      estimatedDuration: json['estimated_duration']?.toString(),
      color: parsed,
    );
  }

  final IconData icon;
  final String name;
  final int? startingPrice;
  final String currency;
  final String? estimatedDuration;
  final Color? color;

  static int? _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v == null) return null;
    return int.tryParse(v.toString());
  }

  static IconData _icon(dynamic v) {
    final s = (v ?? '').toString().trim().toLowerCase();
    switch (s) {
      case 'bolt':
      case 'electrical_installation':
        return Icons.bolt_rounded;
      case 'handyman':
      case 'build_circle':
      case 'repair':
        return Icons.handyman_outlined;
      case 'plumbing':
      case 'water_drop':
      case 'pipe':
        return Icons.water_drop_rounded;
      case 'paint':
      case 'format_paint':
        return Icons.format_paint_outlined;
      case 'cleaning_services':
      case 'cleaning':
        return Icons.cleaning_services_outlined;
      case 'hvac':
      case 'ac_unit':
      case 'air':
        return Icons.ac_unit_rounded;
      case 'carpenter':
      case 'wood':
      case 'carpentry':
        return Icons.carpenter_rounded;
      case 'mover':
      case 'local_shipping':
      case 'transport':
        return Icons.local_shipping_rounded;
      default:
        return Icons.construction_rounded;
    }
  }
}

class PublicReviewItem {
  const PublicReviewItem({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.dateLabel,
    this.reviewerAvatar,
    this.verifiedCustomer = false,
    this.taskTitle,
  });

  factory PublicReviewItem.fromJson(Map<String, dynamic> json) {
    return PublicReviewItem(
      reviewerName: (json['reviewer_name'] ?? 'Customer').toString(),
      rating: _double(json['rating']) ?? 0,
      comment: (json['comment'] ?? '').toString(),
      dateLabel: (json['date_label'] ?? '').toString(),
      reviewerAvatar: json['reviewer_avatar']?.toString(),
      verifiedCustomer: json['verified_customer'] == true || json['verified_customer'] == 1,
      taskTitle: json['task_title']?.toString(),
    );
  }

  final String reviewerName;
  final double rating;
  final String comment;
  final String dateLabel;
  final String? reviewerAvatar;
  final bool verifiedCustomer;
  final String? taskTitle;

  static double? _double(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v == null) return null;
    return double.tryParse(v.toString());
  }
}

class PublicPortfolioItem {
  const PublicPortfolioItem({
    required this.title,
    required this.imagePath,
    this.description,
    this.category,
    this.tags = const [],
    this.isFeatured = false,
  });

  factory PublicPortfolioItem.fromJson(Map<String, dynamic> json) {
    final tags = <String>[];
    final t = json['tags'] as List?;
    if (t != null) {
      for (final x in t) {
        final s = x?.toString();
        if (s != null && s.trim().isNotEmpty) tags.add(s.trim());
      }
    }
    return PublicPortfolioItem(
      title: (json['title'] ?? '').toString(),
      imagePath: (json['image_path'] ?? '').toString(),
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      tags: tags,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
    );
  }

  final String title;
  final String imagePath;
  final String? description;
  final String? category;
  final List<String> tags;
  final bool isFeatured;
}
