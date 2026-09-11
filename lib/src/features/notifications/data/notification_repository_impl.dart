import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_exception.dart';
import '../../../core/networking/api_client.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';
import 'notification_api.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    api: NotificationApi(ref.watch(apiClientProvider)),
    readAuth: () => ref.read(authControllerProvider),
    expireSession: () =>
        ref.read(authControllerProvider.notifier).expireSession(),
  );
});

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required this.api,
    required this.readAuth,
    required this.expireSession,
  });

  final NotificationApi api;
  final AuthState Function() readAuth;
  final Future<void> Function() expireSession;

  Future<T> _authenticated<T>(Future<T> Function() request) async {
    final requestedUser = readAuth().user;
    if (readAuth().status != AuthStatus.authenticated ||
        requestedUser == null ||
        (!requestedUser.isClient && !requestedUser.isTasker)) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    try {
      final result = await request();
      final current = readAuth().user;
      if (current?.id != requestedUser.id ||
          current?.role != requestedUser.role) {
        throw const ApiException(statusCode: 403, message: 'err_forbidden');
      }
      return result;
    } on ApiException catch (error) {
      final current = readAuth().user;
      if (error.statusCode == 401 &&
          current?.id == requestedUser.id &&
          current?.role == requestedUser.role) {
        await expireSession();
      }
      rethrow;
    }
  }

  @override
  Future<NotificationPage> list({required int page, int perPage = 20}) {
    return _authenticated(() async {
      final response = await api.list(page: page, perPage: perPage);
      return _parsePage(response, requestedPage: page);
    });
  }

  @override
  Future<int> unreadCount() async {
    final page = await list(page: 1, perPage: 1);
    return page.unreadCount;
  }

  @override
  Future<AppNotification> markAsRead(String id) {
    return _authenticated(() async {
      final response = await api.markAsRead(id);
      final data = _map(response['data']);
      if (data.isEmpty) {
        throw const FormatException('Invalid mark-as-read response');
      }
      return AppNotification.fromJson(data);
    });
  }

  @override
  Future<void> markAllAsRead() {
    return _authenticated(() async {
      // The current backend has no bulk endpoint. Always request page one because
      // marking a batch as read removes it from the unread-only result set.
      for (var batch = 0; batch < 100; batch++) {
        final response = await api.list(page: 1, perPage: 50, unreadOnly: true);
        final page = _parsePage(response, requestedPage: 1);
        if (page.items.isEmpty) return;
        for (final notification in page.items) {
          await api.markAsRead(notification.id);
        }
        if (page.items.length < 50) return;
      }
    });
  }

  @override
  Future<void> delete(String id) =>
      _authenticated(() async => api.delete(id).then((_) {}));

  @override
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) =>
      _authenticated(() async => api
          .registerDeviceToken(token: token, platform: platform)
          .then((_) {}));

  static NotificationPage _parsePage(
    Map<String, dynamic> response, {
    required int requestedPage,
  }) {
    final topData = response['data'];
    final dataMap = _map(topData);

    dynamic rawItems;
    Map<String, dynamic> pagination = const {};
    var unreadCount = _int(response['unread_count']);

    if (dataMap.isNotEmpty) {
      rawItems = dataMap['notifications'];
      unreadCount ??= _int(dataMap['unread_count']);
      pagination = _map(dataMap['pagination']);

      // Standard Laravel paginator nested under data.
      if (rawItems == null && dataMap['data'] is List) {
        rawItems = dataMap['data'];
        pagination = dataMap;
      }
    }

    // data may itself be the notification list.
    rawItems ??= topData is List ? topData : response['notifications'];
    final meta = _map(response['meta']);
    if (pagination.isEmpty && meta.isNotEmpty) pagination = meta;

    final items = <AppNotification>[];
    final seen = <String>{};
    if (rawItems is List) {
      for (final raw in rawItems) {
        final json = _map(raw);
        if (json.isEmpty) continue;
        final notification = AppNotification.fromJson(json);
        if (notification.id.isNotEmpty && seen.add(notification.id)) {
          items.add(notification);
        }
      }
    }

    final currentPage = _int(pagination['current_page']) ?? requestedPage;
    final lastPage = _int(pagination['last_page']) ?? currentPage;
    unreadCount ??= items.where((item) => !item.isRead).length;

    return NotificationPage(
      items: items,
      currentPage: currentPage,
      lastPage: lastPage < currentPage ? currentPage : lastPage,
      unreadCount: unreadCount < 0 ? 0 : unreadCount,
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  static int? _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
