import 'admin_dashboard_models.dart';

class AdminDashboardSummary {
  const AdminDashboardSummary({
    required this.usersCount,
    required this.tasksCount,
    required this.disputesCount,
    required this.revenue,
    this.completedTasks,
    this.activeTasks,
    this.paidVolume,
    this.analytics,
  });

  final int usersCount;
  final int tasksCount;
  final int disputesCount;
  final double revenue;
  final int? completedTasks;
  final int? activeTasks;
  final double? paidVolume;
  final AdminDashboardAnalytics? analytics;

  factory AdminDashboardSummary.fromJson(Map<String, dynamic> json) {
    return AdminDashboardSummary(
      usersCount: _toInt(json['users_count']),
      tasksCount: _toInt(json['tasks_count']),
      disputesCount: _toInt(json['disputes_count']),
      revenue: _toDouble(json['revenue']),
      completedTasks: json['completed_tasks'] == null
          ? null
          : analyticsCount(json['completed_tasks']),
      activeTasks: json['active_tasks'] == null
          ? null
          : analyticsCount(json['active_tasks']),
      paidVolume: json['completed_payments_amount'] == null
          ? null
          : _toDouble(json['completed_payments_amount']),
      analytics: json['analytics'] == null
          ? null
          : AdminDashboardAnalytics.fromJson(
              Map<String, dynamic>.from(json['analytics'] as Map)),
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
