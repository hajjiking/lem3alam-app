import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_dashboard_repository.dart';
import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => const MockDashboardRepository(),
);

final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(
        DashboardController.new);

class DashboardState {
  const DashboardState({
    required this.snapshot,
    this.selectedFilter = DashboardTaskFilter.pending,
    this.performanceRange = DashboardPerformanceRange.week,
    this.isOnline = true,
  });

  final DashboardSnapshot snapshot;
  final DashboardTaskFilter selectedFilter;
  final DashboardPerformanceRange performanceRange;
  final bool isOnline;

  List<DashboardTask> get visibleTasks {
    return switch (selectedFilter) {
      DashboardTaskFilter.pending => snapshot.tasks
          .where(
            (task) =>
                task.status == DashboardTaskStatus.fresh ||
                task.status == DashboardTaskStatus.pending,
          )
          .toList(growable: false),
      DashboardTaskFilter.accepted => snapshot.tasks
          .where((task) => task.status == DashboardTaskStatus.accepted)
          .toList(growable: false),
      DashboardTaskFilter.completed => snapshot.tasks
          .where((task) => task.status == DashboardTaskStatus.completed)
          .toList(growable: false),
    };
  }

  DashboardState copyWith({
    DashboardTaskFilter? selectedFilter,
    DashboardPerformanceRange? performanceRange,
    bool? isOnline,
  }) {
    return DashboardState(
      snapshot: snapshot,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      performanceRange: performanceRange ?? this.performanceRange,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class DashboardController extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return DashboardState(
      snapshot: ref.watch(dashboardRepositoryProvider).loadDashboard(),
    );
  }

  void selectFilter(DashboardTaskFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void selectPerformanceRange(DashboardPerformanceRange range) {
    state = state.copyWith(performanceRange: range);
  }

  void toggleAvailability() {
    state = state.copyWith(isOnline: !state.isOnline);
  }
}
