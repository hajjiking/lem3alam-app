import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/notifications/application/notification_center_controller.dart';
import 'package:lem3alam_mobile/src/features/notifications/data/notification_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/notifications/domain/app_notification.dart';
import 'package:lem3alam_mobile/src/features/notifications/domain/notification_repository.dart';

void main() {
  late _FakeNotificationRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeNotificationRepository();
    container = ProviderContainer(overrides: [
      notificationRepositoryProvider.overrideWithValue(repository),
      authControllerProvider.overrideWith(_AuthenticatedController.new),
    ]);
  });

  tearDown(() => container.dispose());

  test('mark as read updates item and unread count optimistically', () async {
    final controller = container.read(notificationCenterProvider.notifier);
    await controller.fetchNotifications();
    final item = container.read(notificationCenterProvider).notifications.first;

    final request = controller.markAsRead(item);
    final optimistic = container.read(notificationCenterProvider);
    expect(optimistic.notifications.first.isRead, isTrue);
    expect(optimistic.unreadCount, 1);
    await request;
    expect(repository.readIds, ['1']);
  });

  test('mark all read updates every item and count', () async {
    final controller = container.read(notificationCenterProvider.notifier);
    await controller.fetchNotifications();

    await controller.markAllAsRead();

    final state = container.read(notificationCenterProvider);
    expect(state.unreadCount, 0);
    expect(state.notifications.every((item) => item.isRead), isTrue);
    expect(repository.markedAll, isTrue);
  });

  test('pagination deduplicates notification ids', () async {
    final controller = container.read(notificationCenterProvider.notifier);
    await controller.fetchNotifications();
    await controller.loadMoreNotifications();

    final state = container.read(notificationCenterProvider);
    expect(state.notifications.map((item) => item.id), ['1', '2', '3']);
    expect(state.hasMore, isFalse);
  });
}

class _AuthenticatedController extends AuthController {
  @override
  AuthState build() => const AuthState(
        status: AuthStatus.authenticated,
        user: User(
          id: 10,
          name: 'Client',
          email: 'client@example.com',
          role: 'client',
          status: 'active',
          city: 'Rabat',
        ),
      );
}

class _FakeNotificationRepository implements NotificationRepository {
  final readIds = <String>[];
  bool markedAll = false;

  @override
  Future<NotificationPage> list({required int page, int perPage = 20}) async {
    if (page == 1) {
      return NotificationPage(
        items: [_notification('1'), _notification('2')],
        currentPage: 1,
        lastPage: 2,
        unreadCount: 2,
      );
    }
    return NotificationPage(
      items: [_notification('2'), _notification('3', isRead: true)],
      currentPage: 2,
      lastPage: 2,
      unreadCount: 2,
    );
  }

  @override
  Future<AppNotification> markAsRead(String id) async {
    readIds.add(id);
    return _notification(id, isRead: true);
  }

  @override
  Future<void> markAllAsRead() async => markedAll = true;

  @override
  Future<int> unreadCount() async => 2;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {}

  static AppNotification _notification(String id, {bool isRead = false}) {
    return AppNotification(
      id: id,
      type: 'task_updated',
      title: 'Task updated',
      message: 'Task details changed.',
      isRead: isRead,
      createdAt: DateTime(2026, 9, 1),
      taskId: 42,
    );
  }
}
