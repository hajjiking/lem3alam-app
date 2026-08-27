import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';

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
    this.hasLoaded = false,
    this.error,
  });

  final DashboardSnapshot snapshot;
  final DashboardTaskFilter selectedFilter;
  final DashboardPerformanceRange performanceRange;
  final bool isLoading;
  final bool hasLoaded;
  final Object? error;

  List<DashboardTask> get visibleTasks {
    final tasks = snapshot.tasks.where((task) => !task.isCancelled);
    return switch (selectedFilter) {
      DashboardTaskFilter.pending => tasks
          .where(
            (task) =>
                task.status == DashboardTaskStatus.fresh ||
                task.status == DashboardTaskStatus.pending,
          )
          .toList(growable: false),
      DashboardTaskFilter.accepted => tasks
          .where((task) => task.status == DashboardTaskStatus.accepted)
          .toList(growable: false),
      DashboardTaskFilter.completed => tasks
          .where((task) => task.status == DashboardTaskStatus.completed)
          .toList(growable: false),
    };
  }

  DashboardState copyWith({
    DashboardSnapshot? snapshot,
    DashboardTaskFilter? selectedFilter,
    DashboardPerformanceRange? performanceRange,
    bool? isLoading,
    bool? hasLoaded,
    Object? error,
    bool clearError = false,
  }) {
    return DashboardState(
      snapshot: snapshot ?? this.snapshot,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      performanceRange: performanceRange ?? this.performanceRange,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class DashboardController extends Notifier<DashboardState> {
  var _requestVersion = 0;

  @override
  DashboardState build() {
    final identity = ref.watch(authControllerProvider
        .select((state) => (state.user?.id, state.user?.role)));
    ref.watch(dashboardRepositoryProvider);
    final version = ++_requestVersion;
    ref.onDispose(() => _requestVersion++);
    if (identity.$2 != 'tasker') {
      return const DashboardState(snapshot: DashboardSnapshot.empty);
    }
    Future.microtask(() {
      if (ref.mounted && version == _requestVersion) {
        load();
      }
    });
    return const DashboardState(
        snapshot: DashboardSnapshot.empty, isLoading: true);
  }

  Future<void> load() async {
    if (ref.read(authControllerProvider).user?.isTasker != true) return;
    final version = ++_requestVersion;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final snapshot =
          await ref.read(dashboardRepositoryProvider).fetchDashboard();
      if (!ref.mounted || version != _requestVersion) return;
      state = state.copyWith(
        snapshot: snapshot,
        isLoading: false,
        hasLoaded: true,
        clearError: true,
      );
    } catch (error) {
      if (!ref.mounted || version != _requestVersion) return;
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
