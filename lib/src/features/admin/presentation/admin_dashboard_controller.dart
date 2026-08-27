import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/pagination.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/admin_dashboard_models.dart';
import '../data/admin_repository_impl.dart';
import '../domain/admin_dashboard_summary.dart';
import '../domain/admin_nearby_task_settings.dart';
import '../domain/admin_report_item.dart';
import '../domain/admin_user_item.dart';

final _adminRefreshTickProvider =
    NotifierProvider<_AdminRefreshTick, int>(_AdminRefreshTick.new);

class _AdminRefreshTick extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final adminDashboardProvider =
    FutureProvider<AdminDashboardSummary>((ref) async {
  ref.watch(_adminRefreshTickProvider);
  ref.watch(authControllerProvider.select((state) => state.user?.id));
  return ref.watch(adminRepositoryProvider).fetchDashboard();
}, retry: (count, error) => null);

final adminDashboardRangeProvider =
    NotifierProvider<AdminDashboardRangeController, AdminDashboardRange>(
        AdminDashboardRangeController.new);

class AdminDashboardRangeController extends Notifier<AdminDashboardRange> {
  @override
  AdminDashboardRange build() => AdminDashboardRange.week;
  void select(AdminDashboardRange range) => state = range;
}

final adminUsersProvider =
    FutureProvider<Paginated<AdminUserItem>>((ref) async {
  ref.watch(_adminRefreshTickProvider);
  return ref.watch(adminRepositoryProvider).fetchUsers(page: 1, perPage: 50);
});

final adminReportsProvider =
    FutureProvider<Paginated<AdminReportItem>>((ref) async {
  ref.watch(_adminRefreshTickProvider);
  return ref.watch(adminRepositoryProvider).fetchReports(page: 1, perPage: 50);
});

final adminNearbyTaskSettingsProvider =
    FutureProvider<AdminNearbyTaskSettings>((ref) async {
  ref.watch(_adminRefreshTickProvider);
  return ref.watch(adminRepositoryProvider).fetchNearbyTaskSettings();
});

final adminActionControllerProvider =
    AsyncNotifierProvider<AdminActionController, void>(
        AdminActionController.new);

class AdminActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> refreshAll() async {
    ref.read(_adminRefreshTickProvider.notifier).bump();
  }

  Future<void> verifyUser(int userId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(adminRepositoryProvider).verifyUser(userId);
      await refreshAll();
    });
  }

  Future<void> toggleBan(AdminUserItem user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (user.isBanned) {
        await ref.read(adminRepositoryProvider).unbanUser(user.id);
      } else {
        await ref
            .read(adminRepositoryProvider)
            .banUser(user.id, reason: 'Banned from mobile admin');
      }
      await refreshAll();
    });
  }

  Future<void> toggleSuspension(AdminUserItem user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (user.isSuspended) {
        await ref.read(adminRepositoryProvider).unsuspendUser(user.id);
      } else {
        await ref.read(adminRepositoryProvider).suspendUser(
              user.id,
              days: 7,
              reason: 'Suspended from mobile admin',
            );
      }
      await refreshAll();
    });
  }

  Future<void> resolveReport(int reportId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(adminRepositoryProvider).resolveReport(
            reportId,
            notes: 'Resolved from mobile admin',
          );
      await refreshAll();
    });
  }

  Future<void> dismissReport(int reportId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(adminRepositoryProvider).dismissReport(
            reportId,
            notes: 'Dismissed from mobile admin',
          );
      await refreshAll();
    });
  }

  Future<void> updateNearbyTaskSettings(
      AdminNearbyTaskSettings settings) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(adminRepositoryProvider)
          .updateNearbyTaskSettings(settings);
      await refreshAll();
    });
  }
}
