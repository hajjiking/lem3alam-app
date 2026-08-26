enum AdminMetricKind {
  totalUsers,
  totalTasks,
  completedTasks,
  activeTaskers,
  pendingTasks,
  pendingReviews,
}

enum AdminColorKey { primary, success, purple, warning, info, error }

enum AdminTaskStatus { inProgress, completed, pending, cancelled }

enum AdminRecentTaskKind {
  washingMachine,
  kitchenFaucet,
  ledLights,
}

enum AdminCategoryKind { homeRepairs, plumbing, electrical, cleaning, painting }

enum AdminDashboardRange { week, month }

class AdminMetric {
  const AdminMetric({
    required this.kind,
    required this.value,
    required this.deltaPercent,
    required this.colorKey,
  });

  final AdminMetricKind kind;
  final int value;
  final double deltaPercent;
  final AdminColorKey colorKey;

  bool get isPositive => deltaPercent >= 0;

  AdminMetric copyWith({int? value}) {
    return AdminMetric(
      kind: kind,
      value: value ?? this.value,
      deltaPercent: deltaPercent,
      colorKey: colorKey,
    );
  }
}

class TaskSeriesPoint {
  const TaskSeriesPoint({
    required this.dayIndex,
    required this.posted,
    required this.inProgress,
    required this.completed,
  });

  final int dayIndex;
  final double posted;
  final double inProgress;
  final double completed;
}

class TaskStatusSlice {
  const TaskStatusSlice({
    required this.status,
    required this.value,
    required this.colorKey,
  });

  final AdminTaskStatus status;
  final int value;
  final AdminColorKey colorKey;
}

class RecentTaskAdminModel {
  const RecentTaskAdminModel({
    required this.kind,
    required this.customerName,
    required this.status,
    required this.minutesAgo,
    required this.thumbnailUrl,
  });

  final AdminRecentTaskKind kind;
  final String customerName;
  final AdminTaskStatus status;
  final int minutesAgo;
  final String thumbnailUrl;
}

class CategoryStat {
  const CategoryStat({
    required this.kind,
    required this.count,
    required this.percent,
    required this.colorKey,
  });

  final AdminCategoryKind kind;
  final int count;
  final double percent;
  final AdminColorKey colorKey;
}

class AdminDashboardSnapshot {
  const AdminDashboardSnapshot({
    required this.metrics,
    required this.weeklySeries,
    required this.monthlySeries,
    required this.statusSlices,
    required this.recentTasks,
    required this.categories,
  });

  final List<AdminMetric> metrics;
  final List<TaskSeriesPoint> weeklySeries;
  final List<TaskSeriesPoint> monthlySeries;
  final List<TaskStatusSlice> statusSlices;
  final List<RecentTaskAdminModel> recentTasks;
  final List<CategoryStat> categories;

  int valueFor(AdminMetricKind kind) {
    return metrics.firstWhere((metric) => metric.kind == kind).value;
  }

  AdminDashboardSnapshot withLiveTotals({
    required int usersCount,
    required int tasksCount,
  }) {
    return AdminDashboardSnapshot(
      metrics: [
        for (final metric in metrics)
          switch (metric.kind) {
            AdminMetricKind.totalUsers when usersCount > 0 =>
              metric.copyWith(value: usersCount),
            AdminMetricKind.totalTasks when tasksCount > 0 =>
              metric.copyWith(value: tasksCount),
            _ => metric,
          },
      ],
      weeklySeries: weeklySeries,
      monthlySeries: monthlySeries,
      statusSlices: statusSlices,
      recentTasks: recentTasks,
      categories: categories,
    );
  }
}
