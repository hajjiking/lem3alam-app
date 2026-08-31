import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/notification_payload.dart';

enum NotificationSource { foreground, background, terminated, local }

class NotificationEvent {
  const NotificationEvent({
    required this.payload,
    required this.source,
    required this.receivedAt,
  });

  final NotificationPayload payload;
  final NotificationSource source;
  final DateTime receivedAt;
}

class NotificationState {
  const NotificationState({this.lastReceived, this.pendingTap});

  final NotificationEvent? lastReceived;
  final NotificationEvent? pendingTap;

  NotificationState copyWith({
    NotificationEvent? lastReceived,
    NotificationEvent? pendingTap,
    bool clearPendingTap = false,
  }) {
    return NotificationState(
      lastReceived: lastReceived ?? this.lastReceived,
      pendingTap: clearPendingTap ? null : pendingTap ?? this.pendingTap,
    );
  }
}

final notificationStateProvider =
    NotifierProvider<NotificationStateNotifier, NotificationState>(
  NotificationStateNotifier.new,
);

class NotificationStateNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() => const NotificationState();

  void received(NotificationPayload payload, NotificationSource source) {
    state = state.copyWith(
      lastReceived: NotificationEvent(
        payload: payload,
        source: source,
        receivedAt: DateTime.now(),
      ),
    );
  }

  void tapped(NotificationPayload payload, NotificationSource source) {
    state = state.copyWith(
      pendingTap: NotificationEvent(
        payload: payload,
        source: source,
        receivedAt: DateTime.now(),
      ),
    );
  }

  void consumeTap() => state = state.copyWith(clearPendingTap: true);
}
