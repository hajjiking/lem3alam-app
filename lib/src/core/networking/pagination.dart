class Paginated<T> {
  Paginated({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  bool get hasNextPage => currentPage < lastPage;

  static Paginated<T> fromLaravel<T>(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) itemFromJson,
  }) {
    final data = (json['data'] as List?) ?? const [];
    return Paginated<T>(
      items: data.whereType<Map<String, dynamic>>().map(itemFromJson).toList(),
      currentPage: _intOr(json['current_page'], 1),
      lastPage: _intOr(json['last_page'], 1),
      perPage: _intOr(json['per_page'], data.length),
      total: _intOr(json['total'], data.length),
    );
  }
}

int _intOr(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}
