import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_admin_dashboard_repository.dart';
import '../domain/admin_dashboard_content_repository.dart';
import '../domain/admin_dashboard_models.dart';

final adminDashboardContentRepositoryProvider =
    Provider<AdminDashboardContentRepository>(
  (ref) => const MockAdminDashboardRepository(),
);

final adminDashboardViewControllerProvider =
    NotifierProvider<AdminDashboardViewController, AdminDashboardViewState>(
  AdminDashboardViewController.new,
);

class AdminDashboardViewState {
  const AdminDashboardViewState({
    required this.snapshot,
    this.range = AdminDashboardRange.week,
    this.isOnline = true,
  });

  final AdminDashboardSnapshot snapshot;
  final AdminDashboardRange range;
  final bool isOnline;

  List<TaskSeriesPoint> get visibleSeries => switch (range) {
        AdminDashboardRange.week => snapshot.weeklySeries,
        AdminDashboardRange.month => snapshot.monthlySeries,
      };

  AdminDashboardViewState copyWith({
    AdminDashboardRange? range,
    bool? isOnline,
  }) {
    return AdminDashboardViewState(
      snapshot: snapshot,
      range: range ?? this.range,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class AdminDashboardViewController extends Notifier<AdminDashboardViewState> {
  @override
  AdminDashboardViewState build() {
    return AdminDashboardViewState(
      snapshot:
          ref.watch(adminDashboardContentRepositoryProvider).loadDashboard(),
    );
  }

  void selectRange(AdminDashboardRange value) {
    state = state.copyWith(range: value);
  }

  void toggleAvailability() {
    state = state.copyWith(isOnline: !state.isOnline);
  }
}
