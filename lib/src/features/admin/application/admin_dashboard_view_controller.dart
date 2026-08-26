import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminDashboardViewControllerProvider =
    NotifierProvider<AdminDashboardViewController, AdminDashboardViewState>(
      AdminDashboardViewController.new,
);

class AdminDashboardViewState {
  const AdminDashboardViewState({
    this.isOnline = true,
  });

  final bool isOnline;

  AdminDashboardViewState copyWith({
    bool? isOnline,
  }) {
    return AdminDashboardViewState(
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class AdminDashboardViewController extends Notifier<AdminDashboardViewState> {
  @override
  AdminDashboardViewState build() => const AdminDashboardViewState();

  void toggleAvailability() {
    state = state.copyWith(isOnline: !state.isOnline);
  }
}
