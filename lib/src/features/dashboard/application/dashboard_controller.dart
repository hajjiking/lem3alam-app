import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_repository_impl.dart';
import '../domain/dashboard_models.dart';

final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(
        DashboardController.new);

class DashboardState {
  const DashboardState({
    required this.snapshot,
    this.selectedFilter = DashboardTaskFilter.pending,
    this.performanceRange = DashboardPerformanceRange.week,
    this.isLoading = false,
    this.error,
  });

  final DashboardSnapshot snapshot;
  final DashboardTaskFilter selectedFilter;
  final DashboardPerformanceRange performanceRange;
  final bool isLoading;
  final Object? error;

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
    DashboardSnapshot? snapshot,
    DashboardTaskFilter? selectedFilter,
    DashboardPerformanceRange? performanceRange,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return DashboardState(
      snapshot: snapshot ?? this.snapshot,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      performanceRange: performanceRange ?? this.performanceRange,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class DashboardController extends Notifier<DashboardState> {
  var _started = false;

  @override
  DashboardState build() {
    if (!_started) {
      _started = true;
      Future.microtask(load);
    }
    return const DashboardState(snapshot: DashboardSnapshot.empty);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final snapshot =
          await ref.read(dashboardRepositoryProvider).fetchDashboard();
      state = state.copyWith(
        snapshot: snapshot,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  void selectFilter(DashboardTaskFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void selectPerformanceRange(DashboardPerformanceRange range) {
    state = state.copyWith(performanceRange: range);
  }
}
