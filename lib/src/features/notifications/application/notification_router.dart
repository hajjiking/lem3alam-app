import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/app_router.dart';
import '../domain/app_notification.dart';
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
    if (payload.role != null && payload.role != currentRole) return null;
    final target = payload.targetId;
    final taskId = payload.taskId ?? int.tryParse(target ?? '');
    final conversationId =
        payload.userId ?? payload.conversationId ?? int.tryParse(target ?? '');
    return NotificationRouteResolver.resolve(
      type: payload.type,
      role: currentRole,
      taskId: taskId,
      conversationId: conversationId,
      paymentId: payload.paymentId,
      userId: payload.userId,
    );
  }

  String? locationForNotification(
    AppNotification notification, {
    required String currentRole,
    required int currentUserId,
  }) {
    return NotificationRouteResolver.resolve(
      type: notification.type,
      role: currentRole,
      taskId: notification.taskId,
      conversationId: notification.userId ?? notification.conversationId,
      paymentId: notification.paymentId,
      userId: notification.userId ?? currentUserId,
    );
  }

  bool route(NotificationPayload payload, {required String currentRole}) {
    final location = locationFor(payload, currentRole: currentRole);
    if (location == null) return false;
    _router.go(location);
    return true;
  }

  bool routeNotification(
    AppNotification notification, {
    required String currentRole,
    required int currentUserId,
  }) {
    final location = locationForNotification(
      notification,
      currentRole: currentRole,
      currentUserId: currentUserId,
    );
    if (location == null) return false;
    _router.go(location);
    return true;
  }
}

abstract final class NotificationRouteResolver {
  static const _taskTypes = {
    'application_received',
    'application_withdrawn',
    'application_accepted',
    'application_rejected',
    'task_assigned',
    'task_status_updated',
    'task_status_change',
    'task_started',
    'task_completed',
    'task_cancelled',
    'task_updated',
    'task_deadline_reminder',
    'task_expired',
    'task_completion_confirmed',
    'new_request',
    'new_task_nearby',
  };
  static const _messageTypes = {'new_message', 'message_received'};
  static const _paymentTypes = {
    'payment_received',
    'payment_completed',
    'payment_failed',
    'refund_updated',
    'earning_added',
    'platform_fee_applied',
    'payout_processing',
    'payout_completed',
    'payout_failed',
  };

  static String? resolve({
    required String type,
    required String role,
    int? taskId,
    int? conversationId,
    int? paymentId,
    int? userId,
  }) {
    final normalized = type.toLowerCase();
    if (_taskTypes.contains(normalized) && taskId != null) {
      return '/tasks/$taskId';
    }
    if (_messageTypes.contains(normalized) && conversationId != null) {
      return '/messages/$conversationId';
    }
    if (_paymentTypes.contains(normalized)) {
      return role == 'client' ? '/payments' : '/earnings';
    }
    if (normalized == 'review_received' && userId != null) {
      return '/taskers/$userId/reviews';
    }
    // No dispute/announcement detail routes exist in the current app.
    return null;
  }
}
