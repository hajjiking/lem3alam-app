enum DashboardTaskFilter { pending, accepted, completed }

enum DashboardTaskStatus { fresh, pending, accepted, completed }

enum DashboardTaskKind {
  repairWashingMachine,
  fixKitchenFaucet,
  installLedLights,
}

enum DashboardTaskCategory { homeAppliance, plumbing, electrical }

enum DashboardCity { rabat, casablanca, marrakech }

enum DashboardPerformanceRange { week, month }

class DashboardStats {
  const DashboardStats({
    required this.activeTasks,
    required this.completedTasks,
    required this.totalEarnings,
    required this.rating,
    required this.pendingTasks,
    required this.acceptedTasks,
  });

  final int activeTasks;
  final int completedTasks;
  final int totalEarnings;
  final double rating;
  final int pendingTasks;
  final int acceptedTasks;
}

class DashboardTask {
  const DashboardTask({
    required this.id,
    required this.kind,
    required this.category,
    required this.city,
    required this.hoursAgo,
    required this.status,
    required this.price,
  });

  final int id;
  final DashboardTaskKind kind;
  final DashboardTaskCategory category;
  final DashboardCity city;
  final int hoursAgo;
  final DashboardTaskStatus status;
  final int price;
}

class WeeklyPerformancePoint {
  const WeeklyPerformancePoint({required this.dayIndex, required this.value});

  final int dayIndex;
  final double value;
}

class DashboardPerformance {
  const DashboardPerformance({
    required this.earnings,
    required this.tasksCompleted,
    required this.earningsChangePercent,
    required this.tasksChangePercent,
    required this.points,
  });

  final int earnings;
  final int tasksCompleted;
  final int earningsChangePercent;
  final int tasksChangePercent;
  final List<WeeklyPerformancePoint> points;
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.stats,
    required this.tasks,
    required this.performance,
  });

  final DashboardStats stats;
  final List<DashboardTask> tasks;
  final DashboardPerformance performance;

  static const empty = DashboardSnapshot(
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
