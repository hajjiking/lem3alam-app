class AdminDashboardSummary {
  const AdminDashboardSummary({
    required this.usersCount,
    required this.tasksCount,
    required this.disputesCount,
    required this.revenue,
  });

  final int usersCount;
  final int tasksCount;
  final int disputesCount;
  final double revenue;

  factory AdminDashboardSummary.fromJson(Map<String, dynamic> json) {
    return AdminDashboardSummary(
      usersCount: _toInt(json['users_count']),
      tasksCount: _toInt(json['tasks_count']),
      disputesCount: _toInt(json['disputes_count']),
      revenue: _toDouble(json['revenue']),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
