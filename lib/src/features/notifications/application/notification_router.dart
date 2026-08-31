import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_router.dart';
import '../domain/notification_payload.dart';

final notificationRouterProvider = Provider<NotificationRouter>((ref) {
  return NotificationRouter(ref.read(goRouterProvider));
});

class NotificationRouter {
  const NotificationRouter(this._router);

  final GoRouter _router;

  String? locationFor(NotificationPayload payload,
      {required String currentRole}) {
    // Do not allow a payload for another role to cross an authorization boundary.
    if (payload.role != currentRole) return null;

    return switch ((payload.role, payload.type)) {
      ('client', 'task_status_updated') =>
        '/client/tasks/${Uri.encodeComponent(payload.targetId)}',
      ('client', 'new_message') =>
        '/chat/${Uri.encodeComponent(payload.targetId)}',
      ('tasker', 'task_assigned') ||
      ('tasker', 'new_task_nearby') =>
        '/tasker/requests/${Uri.encodeComponent(payload.targetId)}',
      ('tasker', 'payment_received') =>
        '/tasker/earnings/${Uri.encodeComponent(payload.targetId)}',
      _ => null,
    };
  }

  bool route(NotificationPayload payload, {required String currentRole}) {
    final location = locationFor(payload, currentRole: currentRole);
    if (location == null) return false;
    _router.go(location);
    return true;
  }
}
