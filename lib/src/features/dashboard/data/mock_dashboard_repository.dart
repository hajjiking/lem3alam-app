import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  const MockDashboardRepository();

  @override
  DashboardSnapshot loadDashboard() {
    return const DashboardSnapshot(
      stats: DashboardStats(
        activeTasks: 3,
        completedTasks: 24,
        totalEarnings: 1200,
        rating: 4.8,
        pendingTasks: 2,
        acceptedTasks: 1,
      ),
      tasks: [
        DashboardTask(
          id: 1,
          kind: DashboardTaskKind.repairWashingMachine,
          category: DashboardTaskCategory.homeAppliance,
          city: DashboardCity.rabat,
          hoursAgo: 2,
          status: DashboardTaskStatus.fresh,
          price: 120,
        ),
        DashboardTask(
          id: 2,
          kind: DashboardTaskKind.fixKitchenFaucet,
          category: DashboardTaskCategory.plumbing,
          city: DashboardCity.casablanca,
          hoursAgo: 5,
          status: DashboardTaskStatus.fresh,
          price: 100,
        ),
        DashboardTask(
          id: 3,
          kind: DashboardTaskKind.installLedLights,
          category: DashboardTaskCategory.electrical,
          city: DashboardCity.marrakech,
          hoursAgo: 24,
          status: DashboardTaskStatus.pending,
          price: 150,
        ),
      ],
      performance: DashboardPerformance(
        earnings: 1200,
        tasksCompleted: 12,
        earningsChangePercent: 18,
        tasksChangePercent: 20,
        points: [
          WeeklyPerformancePoint(dayIndex: 0, value: 2.0),
          WeeklyPerformancePoint(dayIndex: 1, value: 3.4),
          WeeklyPerformancePoint(dayIndex: 2, value: 5.2),
          WeeklyPerformancePoint(dayIndex: 3, value: 4.0),
          WeeklyPerformancePoint(dayIndex: 4, value: 5.6),
          WeeklyPerformancePoint(dayIndex: 5, value: 4.4),
          WeeklyPerformancePoint(dayIndex: 6, value: 6.8),
        ],
      ),
    );
  }
}
