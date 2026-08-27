enum DashboardTaskFilter { pending, accepted, completed }

enum DashboardTaskStatus { fresh, pending, accepted, completed }

enum DashboardPerformanceRange { week, month }

class DashboardStats {
  const DashboardStats({
    required this.activeTasks,
    required this.completedTasks,
    required this.totalEarnings,
    required this.rating,
    required this.pendingTasks,
    required this.acceptedTasks,
    this.successRate,
  });

  final int activeTasks;
  final int completedTasks;
  final num totalEarnings;
  final double rating;
  final int pendingTasks;
  final int acceptedTasks;
  // Optional API percentage; never infer it from the ten recent tasks.
  final double? successRate;

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        activeTasks: _asInt(json['active_tasks']),
        completedTasks: _asInt(json['completed_tasks']),
        totalEarnings: _asDouble(json['total_earnings']),
        rating: _asDouble(json['rating']),
        pendingTasks: _asInt(json['pending_tasks']),
        acceptedTasks: _asInt(json['accepted_tasks']),
        successRate: _percentage(json['success_rate']),
      );
}

class DashboardTask {
  const DashboardTask({
    required this.id,
    required this.title,
    required this.category,
    required this.city,
    required this.hoursAgo,
    required this.status,
    required this.price,
    this.isCancelled = false,
    this.hasCreatedAt = true,
  });

  final int id;
  final String title;
  final String category;
  final String city;
  final int hoursAgo;
  final DashboardTaskStatus status;
  final num price;
  final bool isCancelled;
  final bool hasCreatedAt;

  factory DashboardTask.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final createdAt = DateTime.tryParse(json['created_at']?.toString() ?? '');
    final age = createdAt == null
        ? 0
        : DateTime.now().toUtc().difference(createdAt.toUtc()).inHours;
    return DashboardTask(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      category: category is Map
          ? category['name']?.toString() ?? ''
          : category?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      hoursAgo: age < 0 ? 0 : age,
      status: _dashboardTaskStatus(json['dashboard_status']?.toString()),
      price: _asDouble(json['budget']),
      isCancelled: json['status'] == 'cancelled',
      hasCreatedAt: createdAt != null,
    );
  }
}

double? _percentage(dynamic value) {
  final parsed = double.tryParse(value?.toString() ?? '');
  return parsed != null && parsed.isFinite && parsed >= 0 && parsed <= 100
      ? parsed
      : null;
}

class WeeklyPerformancePoint {
  const WeeklyPerformancePoint(
      {required this.dayIndex,
      required this.value,
      this.date,
      this.tasksCompleted});

  final int dayIndex;
  final double value;
  final DateTime? date;
  final int? tasksCompleted;

  factory WeeklyPerformancePoint.fromJson(Map<String, dynamic> json) =>
      WeeklyPerformancePoint(
        dayIndex: _asInt(json['day_index']),
        value: _performanceNumber(json['value']).toDouble(),
        date: DateTime.tryParse(json['date']?.toString() ?? ''),
        tasksCompleted: json['tasks_completed'] == null
            ? null
            : _asInt(json['tasks_completed']),
      );
}

class DashboardPerformance {
  const DashboardPerformance({
    required this.earnings,
    required this.tasksCompleted,
    required this.earningsChangePercent,
    required this.tasksChangePercent,
    required this.points,
    this.timezone,
  });

  final num earnings;
  final int tasksCompleted;
  final num? earningsChangePercent;
  final num? tasksChangePercent;
  final List<WeeklyPerformancePoint> points;
  final String? timezone;

  factory DashboardPerformance.fromJson(Map<String, dynamic> json) {
    final points = json['points'];
    if (points is! List || points.any((point) => point is! Map)) {
      throw const FormatException('Invalid performance points');
    }
    return DashboardPerformance(
      earnings: _performanceNumber(json['earnings']),
      tasksCompleted: _performanceNumber(json['tasks_completed']).toInt(),
      earningsChangePercent: _nullableNumber(json['earnings_change_percent']),
      tasksChangePercent: _nullableNumber(json['tasks_change_percent']),
      timezone: json['timezone']?.toString(),
      points: points
          .whereType<Map>()
          .where((point) => point['is_future'] != true)
          .map((point) => WeeklyPerformancePoint.fromJson(
                Map<String, dynamic>.from(point),
              ))
          .toList(growable: false),
    );
  }
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.stats,
    required this.tasks,
    required this.performance,
    this.monthlyPerformance,
    this.hasPerformance = true,
  });

  final DashboardStats stats;
  final List<DashboardTask> tasks;
  final DashboardPerformance performance;
  final DashboardPerformance? monthlyPerformance;
  final bool hasPerformance;

  factory DashboardSnapshot.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'];
    final tasks = json['recent_tasks'];
    final performance = json['performance'];
    final monthlyPerformance = json['monthly_performance'];
    return DashboardSnapshot(
      hasPerformance: performance is Map,
      monthlyPerformance: monthlyPerformance is Map
          ? DashboardPerformance.fromJson(
              Map<String, dynamic>.from(monthlyPerformance))
          : null,
      stats: stats is Map
          ? DashboardStats.fromJson(Map<String, dynamic>.from(stats))
          : empty.stats,
      tasks: tasks is List
          ? tasks
              .whereType<Map>()
              .map((task) => DashboardTask.fromJson(
                    Map<String, dynamic>.from(task),
                  ))
              .toList(growable: false)
          : const [],
      performance: performance is Map
          ? DashboardPerformance.fromJson(
              Map<String, dynamic>.from(performance),
            )
          : empty.performance,
    );
  }

  static const empty = DashboardSnapshot(
    hasPerformance: false,
    stats: DashboardStats(
      activeTasks: 0,
      completedTasks: 0,
      totalEarnings: 0,
      rating: 0,
      pendingTasks: 0,
      acceptedTasks: 0,
    ),
    tasks: [],
    performance: DashboardPerformance(
      earnings: 0,
      tasksCompleted: 0,
      earningsChangePercent: 0,
      tasksChangePercent: 0,
      points: [],
    ),
  );
}

double? _nullableNumber(dynamic value) {
  final number = double.tryParse(value?.toString() ?? '');
  return number != null && number.isFinite ? number : null;
}

num _performanceNumber(dynamic value) {
  final number = num.tryParse(value?.toString() ?? '');
  if (number == null || !number.isFinite || number < 0) {
    throw const FormatException('Invalid tasker performance value');
  }
  return number;
}

int _asInt(dynamic value) => switch (value) {
      num number => number.round(),
      String text => double.tryParse(text)?.round() ?? 0,
      _ => 0,
    };

double _asDouble(dynamic value) => switch (value) {
      num number => number.toDouble(),
      String text => double.tryParse(text) ?? 0,
      _ => 0,
    };

DashboardTaskStatus _dashboardTaskStatus(String? value) => switch (value) {
      'pending' => DashboardTaskStatus.pending,
      'accepted' => DashboardTaskStatus.accepted,
      'completed' => DashboardTaskStatus.completed,
      _ => DashboardTaskStatus.fresh,
    };
