class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.city,
    this.latitude,
    this.longitude,
    required this.budgetMin,
    required this.budgetMax,
    required this.budgetType,
    required this.urgency,
    required this.status,
    this.deadline,
    this.clientId,
    this.categoryName,
    this.categoryNameAr,
    this.categoryNameEn,
    this.categoryNameFr,
    this.categoryNameTranslations = const {},
    this.clientName,
    this.assignedTaskerId,
    this.assignedTaskerName,
    this.isRemote = false,
    this.images = const [],
    this.primaryImageUrl,
    this.distanceKm,
    this.clientRating,
    this.isSaved = false,
  });

  final int id;
  final String title;
  final String description;
  final int? categoryId;
  final String city;
  final double? latitude;
  final double? longitude;
  final double budgetMin;
  final double budgetMax;
  final String budgetType;
  final String urgency;
  final String status;
  final DateTime? deadline;
  final int? clientId;
  final String? categoryName;
  final String? categoryNameAr;
  final String? categoryNameEn;
  final String? categoryNameFr;
  final Map<String, String> categoryNameTranslations;
  final String? clientName;
  final int? assignedTaskerId;
  final String? assignedTaskerName;
  final bool isRemote;
  final List<String> images;
  final String? primaryImageUrl;
  final double? distanceKm;
  final double? clientRating;
  final bool isSaved;

  String? get primaryImagePath => images.isEmpty ? null : images.first;
  String? get primaryImageSource => primaryImageUrl ?? primaryImagePath;

  String? localizedCategoryName(String languageCode) {
    final code = languageCode.toLowerCase();
    final translation = categoryNameTranslations[code];
    if (translation != null && translation.trim().isNotEmpty) {
      return translation.trim();
    }

    final orderedFallbacks = switch (code) {
      'ar' => [categoryNameAr, categoryName, categoryNameFr, categoryNameEn],
      'fr' => [categoryNameFr, categoryName, categoryNameEn, categoryNameAr],
      'en' => [categoryNameEn, categoryName, categoryNameFr, categoryNameAr],
      _ => [categoryName, categoryNameEn, categoryNameFr, categoryNameAr],
    };

    for (final fallback in orderedFallbacks) {
      if (fallback != null && fallback.trim().isNotEmpty) {
        return fallback.trim();
      }
    }

    return null;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final client = json['client'];
    final assignedTasker = json['assigned_tasker'];
    final imagesRaw = json['images'];
    final images = <String>[];
    if (imagesRaw is List) {
      for (final v in imagesRaw) {
        if (v == null) continue;
        final s = v.toString();
        if (s.isNotEmpty) images.add(s);
      }
    }

    String? categoryName;
    String? categoryNameAr;
    String? categoryNameEn;
    String? categoryNameFr;
    final categoryNameTranslations = <String, String>{};
    if (category is Map<String, dynamic>) {
      final translations = category['name_translations'];
      if (translations is Map) {
        for (final entry in translations.entries) {
          final key = entry.key.toString().trim();
          final value = entry.value?.toString().trim() ?? '';
          if (key.isNotEmpty && value.isNotEmpty) {
            categoryNameTranslations[key] = value;
          }
        }
      }
      categoryNameAr = category['name_ar']?.toString().trim();
      categoryNameEn = category['name_en']?.toString().trim();
      categoryNameFr = category['name_fr']?.toString().trim();
      categoryName =
          category['name']?.toString().trim() ??
          categoryNameEn ??
          categoryNameFr ??
          categoryNameAr ??
          categoryNameTranslations['en'] ??
          categoryNameTranslations['fr'] ??
          categoryNameTranslations['ar'];
    }

    return Task(
      id: _intRequired(json['id']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      categoryId: _intOptional(json['category_id']),
      city: (json['city'] ?? json['location'] ?? '').toString(),
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      budgetMin: double.tryParse(json['budget_min']?.toString() ?? '') ?? 0,
      budgetMax: double.tryParse(json['budget_max']?.toString() ?? '') ?? 0,
      budgetType: (json['budget_type'] ?? '').toString(),
      urgency: (json['urgency'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? ''),
      clientId: _intOptional(json['client_id']),
      categoryName: categoryName,
      categoryNameAr: categoryNameAr,
      categoryNameEn: categoryNameEn,
      categoryNameFr: categoryNameFr,
      categoryNameTranslations: categoryNameTranslations,
      clientName: client is Map<String, dynamic> ? client['name']?.toString() : null,
      assignedTaskerId: _intOptional(json['assigned_tasker_id']),
      assignedTaskerName: assignedTasker is Map<String, dynamic> ? assignedTasker['name']?.toString() : null,
      isRemote: json['is_remote'] == true || json['is_remote'] == 1,
      images: images,
      primaryImageUrl: json['primary_image_url']?.toString(),
      distanceKm: double.tryParse(json['distance_km']?.toString() ?? ''),
      clientRating: double.tryParse(json['client_rating']?.toString() ?? ''),
      isSaved: json['is_saved'] == true || json['is_saved']?.toString() == '1',
    );
  }
}

class TaskImageAttachment {
  const TaskImageAttachment({
    required this.bytes,
    required this.filename,
  });

  final List<int> bytes;
  final String filename;
}

class TaskPayload {
  const TaskPayload({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.city,
    required this.budgetMin,
    required this.budgetMax,
    required this.budgetType,
    required this.urgency,
    this.deadline,
    this.paymentMethod,
    this.address,
    this.location,
    this.latitude,
    this.longitude,
    this.isRemote = false,
  });

  final String title;
  final String description;
  final int categoryId;
  final String city;
  final double budgetMin;
  final double budgetMax;
  final String budgetType;
  final String urgency;
  final DateTime? deadline;
  final String? paymentMethod;
  final String? address;
  final String? location;
  final double? latitude;
  final double? longitude;
  final bool isRemote;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category_id': categoryId,
      'city': city,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'budget_type': budgetType,
      'urgency': urgency,
      'deadline': deadline?.toIso8601String().split('T').first,
      'payment_method': paymentMethod,
      'address': address,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'is_remote': isRemote,
    }..removeWhere((key, value) => value == null);
  }
}

class TaskApplicationPayload {
  const TaskApplicationPayload({
    required this.proposal,
    required this.proposedBudget,
    required this.estimatedDuration,
  });

  final String proposal;
  final double proposedBudget;
  final String estimatedDuration;

  Map<String, dynamic> toJson() {
    return {
      'proposal': proposal,
      'proposed_budget': proposedBudget,
      'estimated_duration': estimatedDuration,
    };
  }
}

class CategoryOption {
  const CategoryOption({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.nameFr,
    this.nameTranslations = const {},
    this.imageUrl,
    this.parentId,
  });

  final int id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final String? nameFr;
  final Map<String, String> nameTranslations;
  final String? imageUrl;
  final int? parentId;

  String localizedName(String languageCode) {
    final code = languageCode.toLowerCase();
    final translation = nameTranslations[code];
    if (translation != null && translation.trim().isNotEmpty) {
      return translation.trim();
    }

    final orderedFallbacks = switch (code) {
      'ar' => [nameAr, name, nameFr, nameEn],
      'fr' => [nameFr, name, nameEn, nameAr],
      'en' => [nameEn, name, nameFr, nameAr],
      _ => [name, nameEn, nameFr, nameAr],
    };

    for (final fallback in orderedFallbacks) {
      if (fallback != null && fallback.trim().isNotEmpty) {
        return fallback.trim();
      }
    }

    return '';
  }

  factory CategoryOption.fromJson(Map<String, dynamic> json) {
    final translations = json['name_translations'];
    final mappedTranslations = <String, String>{};
    if (translations is Map) {
      for (final entry in translations.entries) {
        final key = entry.key.toString().trim();
        final value = entry.value?.toString().trim() ?? '';
        if (key.isNotEmpty && value.isNotEmpty) {
          mappedTranslations[key] = value;
        }
      }
    }

    final nameAr = json['name_ar']?.toString().trim();
    final nameEn = json['name_en']?.toString().trim();
    final nameFr = json['name_fr']?.toString().trim();
    final baseName = json['name']?.toString().trim();
    final translatedName =
        baseName ??
        nameEn ??
        nameFr ??
        nameAr ??
        mappedTranslations['en'] ??
        mappedTranslations['fr'] ??
        mappedTranslations['ar'];

    return CategoryOption(
      id: _intRequired(json['id']),
      name: (translatedName ?? '').toString(),
      nameAr: nameAr,
      nameEn: nameEn,
      nameFr: nameFr,
      nameTranslations: mappedTranslations,
      imageUrl: json['image_url']?.toString(),
      parentId: _intOptional(json['parent_id']),
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
