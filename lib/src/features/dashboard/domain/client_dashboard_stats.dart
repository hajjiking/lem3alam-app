import 'dashboard_models.dart';

class ClientDashboardStats {
  const ClientDashboardStats({
    required this.activeTasks,
    required this.completedTasks,
    this.successRate,
  });

  final int activeTasks;
  final int completedTasks;
  final double? successRate;

  factory ClientDashboardStats.fromDashboard(DashboardStats stats) =>
      ClientDashboardStats(
        activeTasks: stats.activeTasks,
        completedTasks: stats.completedTasks,
        successRate: stats.successRate,
      );
}
