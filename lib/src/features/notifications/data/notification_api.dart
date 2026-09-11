import '../../../core/networking/api_client.dart';

abstract final class NotificationEndpoints {
  static const feed = 'notifications';
  static String read(String id) => 'notifications/$id/read';

  // These routes are isolated because the current Laravel backend does not
  // expose them yet. The repository provides a safe fallback for read-all.
  static const readAll = 'notifications/read-all';
  static String delete(String id) => 'notifications/$id';
  static const deviceTokens = 'device-tokens';
}

class NotificationApi {
  NotificationApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> list({
    required int page,
    required int perPage,
    bool unreadOnly = false,
  }) {
    return _client.getJson<Map<String, dynamic>>(
      NotificationEndpoints.feed,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (unreadOnly) 'unread_only': 1,
      },
    );
  }

  Future<Map<String, dynamic>> markAsRead(String id) =>
      _client.postJson<Map<String, dynamic>>(NotificationEndpoints.read(id));

  Future<Map<String, dynamic>> markAllAsRead() =>
      _client.postJson<Map<String, dynamic>>(NotificationEndpoints.readAll);

  Future<Map<String, dynamic>> delete(String id) => _client
      .deleteJson<Map<String, dynamic>>(NotificationEndpoints.delete(id));

  Future<Map<String, dynamic>> registerDeviceToken({
    required String token,
    required String platform,
  }) {
    return _client.postJson<Map<String, dynamic>>(
      NotificationEndpoints.deviceTokens,
      data: {'token': token, 'platform': platform},
    );
  }
}
