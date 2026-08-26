import '../domain/admin_dashboard_content_repository.dart';
import '../domain/admin_dashboard_models.dart';

class MockAdminDashboardRepository implements AdminDashboardContentRepository {
  const MockAdminDashboardRepository();

  @override
  AdminDashboardSnapshot loadDashboard() {
    return const AdminDashboardSnapshot(
      metrics: [
        AdminMetric(
          kind: AdminMetricKind.totalUsers,
          value: 1245,
          deltaPercent: 12.5,
          colorKey: AdminColorKey.primary,
        ),
        AdminMetric(
          kind: AdminMetricKind.totalTasks,
          value: 2568,
          deltaPercent: 15.3,
          colorKey: AdminColorKey.success,
        ),
        AdminMetric(
          kind: AdminMetricKind.completedTasks,
          value: 1987,
          deltaPercent: 18.6,
          colorKey: AdminColorKey.purple,
        ),
        AdminMetric(
          kind: AdminMetricKind.activeTaskers,
          value: 845,
          deltaPercent: 10.4,
          colorKey: AdminColorKey.warning,
        ),
        AdminMetric(
          kind: AdminMetricKind.pendingTasks,
          value: 581,
          deltaPercent: -5.2,
          colorKey: AdminColorKey.warning,
        ),
        AdminMetric(
          kind: AdminMetricKind.pendingReviews,
          value: 73,
          deltaPercent: -8.1,
          colorKey: AdminColorKey.info,
        ),
      ],
      weeklySeries: [
        TaskSeriesPoint(
            dayIndex: 0, posted: 380, inProgress: 180, completed: 40),
        TaskSeriesPoint(
            dayIndex: 1, posted: 470, inProgress: 200, completed: 62),
        TaskSeriesPoint(
            dayIndex: 2, posted: 515, inProgress: 225, completed: 90),
        TaskSeriesPoint(
            dayIndex: 3, posted: 585, inProgress: 280, completed: 122),
        TaskSeriesPoint(
            dayIndex: 4, posted: 650, inProgress: 298, completed: 148),
        TaskSeriesPoint(
            dayIndex: 5, posted: 700, inProgress: 282, completed: 170),
        TaskSeriesPoint(
            dayIndex: 6, posted: 602, inProgress: 252, completed: 198),
      ],
      monthlySeries: [
        TaskSeriesPoint(
            dayIndex: 0, posted: 420, inProgress: 190, completed: 58),
        TaskSeriesPoint(
            dayIndex: 1, posted: 525, inProgress: 235, completed: 94),
        TaskSeriesPoint(
            dayIndex: 2, posted: 610, inProgress: 275, completed: 132),
        TaskSeriesPoint(
            dayIndex: 3, posted: 748, inProgress: 322, completed: 205),
      ],
      statusSlices: [
        TaskStatusSlice(
          status: AdminTaskStatus.completed,
          value: 1987,
          colorKey: AdminColorKey.success,
        ),
        TaskStatusSlice(
          status: AdminTaskStatus.inProgress,
          value: 581,
          colorKey: AdminColorKey.warning,
        ),
        TaskStatusSlice(
          status: AdminTaskStatus.cancelled,
          value: 45,
          colorKey: AdminColorKey.error,
        ),
      ],
      recentTasks: [
        RecentTaskAdminModel(
          kind: AdminRecentTaskKind.washingMachine,
          customerName: 'Ahmed Benali',
          status: AdminTaskStatus.inProgress,
          minutesAgo: 10,
          thumbnailUrl:
              'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=240',
        ),
        RecentTaskAdminModel(
          kind: AdminRecentTaskKind.kitchenFaucet,
          customerName: 'Sara El Amrani',
          status: AdminTaskStatus.completed,
          minutesAgo: 60,
          thumbnailUrl:
              'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=240',
        ),
        RecentTaskAdminModel(
          kind: AdminRecentTaskKind.ledLights,
          customerName: 'Youssef R.',
          status: AdminTaskStatus.pending,
          minutesAgo: 120,
          thumbnailUrl:
              'https://images.unsplash.com/photo-1524484485831-a92ffc0de03f?w=240',
        ),
      ],
      categories: [
        CategoryStat(
          kind: AdminCategoryKind.homeRepairs,
          count: 876,
          percent: 34.1,
          colorKey: AdminColorKey.primary,
        ),
        CategoryStat(
          kind: AdminCategoryKind.plumbing,
          count: 542,
          percent: 21.1,
          colorKey: AdminColorKey.info,
        ),
        CategoryStat(
          kind: AdminCategoryKind.electrical,
          count: 489,
          percent: 19,
          colorKey: AdminColorKey.warning,
        ),
        CategoryStat(
          kind: AdminCategoryKind.cleaning,
          count: 367,
          percent: 14.3,
          colorKey: AdminColorKey.purple,
        ),
        CategoryStat(
          kind: AdminCategoryKind.painting,
          count: 294,
          percent: 11.5,
          colorKey: AdminColorKey.purple,
        ),
      ],
    );
  }
}
