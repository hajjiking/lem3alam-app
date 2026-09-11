import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/features/notifications/application/notification_router.dart';

void main() {
  test('resolves task notifications to existing task details', () {
    expect(
      NotificationRouteResolver.resolve(
        type: 'application_received',
        role: 'client',
        taskId: 125,
      ),
      '/tasks/125',
    );
    expect(
      NotificationRouteResolver.resolve(
        type: 'application_accepted',
        role: 'tasker',
        taskId: 125,
      ),
      '/tasks/125',
    );
  });

  test('resolves role-specific financial destinations', () {
    expect(
      NotificationRouteResolver.resolve(
        type: 'payment_completed',
        role: 'client',
      ),
      '/payments',
    );
    expect(
      NotificationRouteResolver.resolve(
        type: 'payout_completed',
        role: 'tasker',
      ),
      '/earnings',
    );
  });

  test('returns null when the app has no safe target route', () {
    expect(
      NotificationRouteResolver.resolve(
        type: 'dispute_updated',
        role: 'client',
      ),
      isNull,
    );
  });
}
