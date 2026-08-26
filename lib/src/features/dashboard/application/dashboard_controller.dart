import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dashboard_models.dart';

final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(
        DashboardController.new);

class DashboardState {
  const DashboardState({
    required this.snapshot,
    this.selectedFilter = DashboardTaskFilter.pending,
    this.performanceRange = DashboardPerformanceRange.week,
  });

  final DashboardSnapshot snapshot;
  final DashboardTaskFilter selectedFilter;
  final DashboardPerformanceRange performanceRange;

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
  }) {
    return DashboardState(
      snapshot: snapshot,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      performanceRange: performanceRange ?? this.performanceRange,
    );
  }
}

class DashboardController extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return const DashboardState(snapshot: DashboardSnapshot.empty);
  }

  void selectFilter(DashboardTaskFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void selectPerformanceRange(DashboardPerformanceRange range) {
    state = state.copyWith(performanceRange: range);
  }
}
