import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/features/notifications/domain/app_notification.dart';

void main() {
  test('parses Laravel notification shape defensively', () {
    final notification = AppNotification.fromJson({
      'id': 'uuid-1',
      'type': 'application_received',
      'title': 'New application',
      'body': 'Youssef applied to your task.',
      'read_at': null,
      'created_at': '2026-09-01T01:00:00Z',
      'task_id': '125',
      'application_id': 33,
      'sender': {'id': '54', 'avatar': null},
    });

    expect(notification.id, 'uuid-1');
    expect(notification.message, 'Youssef applied to your task.');
    expect(notification.isRead, isFalse);
    expect(notification.taskId, 125);
    expect(notification.applicationId, 33);
    expect(notification.userId, 54);
  });

  test('malformed optional fields never throw', () {
    final notification = AppNotification.fromJson({
      'id': 7,
      'type': null,
      'data': 'invalid',
      'task_id': 'not-an-id',
      'created_at': 'not-a-date',
      'is_read': '1',
    });

    expect(notification.id, '7');
    expect(notification.type, 'system_announcement');
    expect(notification.taskId, isNull);
    expect(notification.createdAt.millisecondsSinceEpoch, 0);
    expect(notification.isRead, isTrue);
  });
}
