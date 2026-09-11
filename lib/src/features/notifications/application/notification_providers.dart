import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routing/app_router.dart';
import '../data/notification_service.dart';
import 'notification_state.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService(
    onReceived: (payload, source) =>
        ref.read(notificationStateProvider.notifier).received(payload, source),
    onTapped: (payload, source) =>
        ref.read(notificationStateProvider.notifier).tapped(payload, source),
    shouldPresentLocalNotification: (payload) {
      if (payload.type != 'new_message' && payload.type != 'message_received') {
        return true;
      }
      final conversation = payload.userId ??
          payload.conversationId ??
          int.tryParse(payload.targetId ?? '');
      if (conversation == null) return true;
      final location = ref
          .read(goRouterProvider)
          .routerDelegate
          .currentConfiguration
          .uri
          .path;
      return location != '/messages/$conversation' &&
          location != '/chat/$conversation';
    },
  );
  ref.onDispose(service.dispose);
  return service;
});

final fcmTokenProvider = StreamProvider<String?>((ref) async* {
  final service = ref.watch(notificationServiceProvider);
  yield service.currentToken;
  yield* service.tokenStream;
});
