import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/notification_repository_impl.dart';
import '../domain/app_notification.dart';
import '../domain/notification_payload.dart';
import '../domain/notification_repository.dart';

class NotificationCenterState {
  const NotificationCenterState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.hasLoaded = false,
    this.error,
    this.lastUpdated,
  });

  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final bool hasLoaded;
  final Object? error;
  final DateTime? lastUpdated;

  NotificationCenterState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    bool? hasLoaded,
    Object? error,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return NotificationCenterState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: clearError ? null : error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final notificationCenterProvider =
    NotifierProvider<NotificationCenterController, NotificationCenterState>(
  NotificationCenterController.new,
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(
    notificationCenterProvider.select((state) => state.unreadCount),
  );
});

class NotificationCenterController extends Notifier<NotificationCenterState> {
  static const _perPage = 20;
  static const staleAfter = Duration(minutes: 2);

  NotificationRepository get _repository =>
      ref.read(notificationRepositoryProvider);

  @override
  NotificationCenterState build() {
    ref.watch(authControllerProvider.select(
      (auth) => (auth.status, auth.user?.id, auth.user?.role),
    ));
    return const NotificationCenterState();
  }

  Future<void> bootstrap() async {
    if (state.hasLoaded || state.isLoading) {
      await fetchUnreadCount();
      return;
    }
    await fetchUnreadCount();
  }

  Future<void> fetchNotifications() => _loadFirstPage(showLoader: true);

  Future<void> refreshNotifications() => _loadFirstPage(showLoader: false);

  Future<void> _loadFirstPage({required bool showLoader}) async {
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: showLoader,
      isLoadingMore: false,
      clearError: true,
    );
    try {
      final page = await _repository.list(page: 1, perPage: _perPage);
      if (!ref.mounted) return;
      state = state.copyWith(
        notifications: _deduplicate(page.items),
        unreadCount: page.unreadCount,
        currentPage: page.currentPage,
        hasMore: page.hasNextPage,
        hasLoaded: true,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
        lastUpdated: DateTime.now(),
      );
    } on Object catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        hasLoaded: true,
        error: error,
      );
    }
  }

  Future<void> loadMoreNotifications() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final page = await _repository.list(
        page: state.currentPage + 1,
        perPage: _perPage,
      );
      if (!ref.mounted) return;
      state = state.copyWith(
        notifications: _deduplicate([
          ...state.notifications,
          ...page.items,
        ]),
        unreadCount: page.unreadCount,
        currentPage: page.currentPage,
        hasMore: page.hasNextPage,
        isLoadingMore: false,
        clearError: true,
        lastUpdated: DateTime.now(),
      );
    } on Object catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoadingMore: false, error: error);
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final count = await _repository.unreadCount();
      if (ref.mounted) {
        state = state.copyWith(
          unreadCount: count,
          clearError: true,
          lastUpdated: DateTime.now(),
        );
      }
    } on Object catch (error) {
      if (ref.mounted && state.notifications.isEmpty) {
        state = state.copyWith(error: error);
      }
    }
  }

  Future<void> refreshIfStale() async {
    final updated = state.lastUpdated;
    if (updated != null && DateTime.now().difference(updated) < staleAfter) {
      return;
    }
    if (state.hasLoaded) {
      await refreshNotifications();
    } else {
      await fetchUnreadCount();
    }
  }

  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    final before = state;
    state = state.copyWith(
      notifications: [
        for (final item in state.notifications)
          if (item.id == notification.id) item.copyWith(isRead: true) else item,
      ],
      unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      clearError: true,
    );
    try {
      await _repository.markAsRead(notification.id);
    } on Object {
      if (ref.mounted) state = before;
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0) return;
    final before = state;
    state = state.copyWith(
      notifications: [
        for (final item in state.notifications) item.copyWith(isRead: true),
      ],
      unreadCount: 0,
      clearError: true,
    );
    try {
      await _repository.markAllAsRead();
    } on Object {
      if (ref.mounted) state = before;
      rethrow;
    }
  }

  Future<void> deleteNotification(AppNotification notification) async {
    final before = state;
    state = state.copyWith(
      notifications: state.notifications
          .where((item) => item.id != notification.id)
          .toList(growable: false),
      unreadCount: notification.isRead
          ? state.unreadCount
          : state.unreadCount > 0
              ? state.unreadCount - 1
              : 0,
    );
    try {
      await _repository.delete(notification.id);
    } on Object {
      if (ref.mounted) state = before;
      rethrow;
    }
  }

  void recordIncoming(NotificationPayload payload) {
    final alreadyLoaded = state.notifications.any(
      (item) => item.id == payload.notificationId,
    );
    if (!alreadyLoaded) {
      state = state.copyWith(unreadCount: state.unreadCount + 1);
    }
    // Reconcile with Laravel without blocking foreground message handling.
    unawaited(state.hasLoaded ? refreshNotifications() : fetchUnreadCount());
  }

  void clear() => state = const NotificationCenterState();

  static List<AppNotification> _deduplicate(
      Iterable<AppNotification> notifications) {
    final seen = <String>{};
    return [
      for (final notification in notifications)
        if (seen.add(notification.id)) notification,
    ];
  }
}
