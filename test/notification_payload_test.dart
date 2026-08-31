import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/features/notifications/domain/notification_payload.dart';

void main() {
  group('NotificationPayload', () {
    const json = <String, dynamic>{
      'notification_id': 'notification-42',
      'type': 'task_status_updated',
      'role': 'client',
      'target_id': '123',
      'created_at': '2026-08-31T12:00:00Z',
    };

    test('round-trips the FCM data payload', () {
      final payload = NotificationPayload.fromJson(json);

      expect(payload.notificationId, 'notification-42');
      expect(payload.type, 'task_status_updated');
      expect(payload.role, 'client');
      expect(payload.targetId, '123');
      expect(payload.createdAt, '2026-08-31T12:00:00Z');
      expect(payload.toJson(), json);
    });

    test('rejects missing required fields', () {
      expect(
        () => NotificationPayload.fromJson({...json}..remove('target_id')),
        throwsFormatException,
      );
    });

    test('rejects unsupported roles', () {
      expect(
        () => NotificationPayload.fromJson({...json, 'role': 'admin'}),
        throwsFormatException,
      );
    });
  });
}
