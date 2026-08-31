import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notification_service.dart';
import 'notification_state.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService(
    onReceived: (payload, source) =>
        ref.read(notificationStateProvider.notifier).received(payload, source),
    onTapped: (payload, source) =>
        ref.read(notificationStateProvider.notifier).tapped(payload, source),
  );
  ref.onDispose(service.dispose);
  return service;
});

final fcmTokenProvider = StreamProvider<String?>((ref) async* {
  final service = ref.watch(notificationServiceProvider);
  yield service.currentToken;
  yield* service.tokenStream;
});
