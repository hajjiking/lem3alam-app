import 'app_notification.dart';

abstract interface class NotificationRepository {
  Future<NotificationPage> list({required int page, int perPage = 20});

  Future<int> unreadCount();

  Future<AppNotification> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> delete(String id);

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  });
}
