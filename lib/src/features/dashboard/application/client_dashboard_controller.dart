import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/dashboard_repository_impl.dart';
import '../domain/dashboard_models.dart';

// Account and language changes must not retain another user's/localization's data.
final clientDashboardProvider =
    FutureProvider.autoDispose<DashboardSnapshot>((ref) {
  final user = ref.watch(authControllerProvider.select((state) => state.user));
  ref.watch(localeControllerProvider);
  if (user?.isClient != true) {
    throw StateError('Client authentication required');
  }
  return ref.watch(dashboardRepositoryProvider).fetchDashboard();
}, retry: (retryCount, error) => null);

final clientDashboardFilterProvider =
    NotifierProvider.autoDispose<ClientDashboardFilter, DashboardTaskFilter>(
        ClientDashboardFilter.new);

class ClientDashboardFilter extends Notifier<DashboardTaskFilter> {
  @override
  DashboardTaskFilter build() => DashboardTaskFilter.pending;

  void select(DashboardTaskFilter filter) => state = filter;
}

List<DashboardTask> clientDashboardTasks(
  DashboardSnapshot snapshot,
  DashboardTaskFilter filter,
) =>
    snapshot.tasks.where((task) {
      if (task.isCancelled) return false;
      return switch (filter) {
        DashboardTaskFilter.pending =>
          task.status == DashboardTaskStatus.fresh ||
              task.status == DashboardTaskStatus.pending,
        DashboardTaskFilter.accepted =>
          task.status == DashboardTaskStatus.accepted,
        DashboardTaskFilter.completed =>
          task.status == DashboardTaskStatus.completed,
      };
    }).toList(growable: false);
