import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../application/notification_state.dart';
import '../domain/notification_payload.dart';

const notificationChannel = AndroidNotificationChannel(
  'lem3alam_high_importance',
  'Important notifications',
  description: 'Task, message, and payment notifications.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Notification messages are rendered by Android/iOS. Render data-only
  // messages here so they are visible while the app is backgrounded.
  if (message.notification == null && message.data.isNotEmpty) {
    final plugin = FlutterLocalNotificationsPlugin();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(settings);
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(notificationChannel);
    await plugin.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      message.data['title']?.toString() ?? 'Lem3alam',
      message.data['body']?.toString() ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'lem3alam_high_importance',
          'Important notifications',
          channelDescription: 'Task, message, and payment notifications.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
      payload: jsonEncode(message.data),
    );
  }
}

typedef TokenRegistrationCallback = Future<void> Function(String token);
typedef NotificationCallback = void Function(
  NotificationPayload payload,
  NotificationSource source,
);

class NotificationService {
  static const _platformCallTimeout = Duration(seconds: 10);

  NotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    required NotificationCallback onReceived,
    required NotificationCallback onTapped,
  })  : _messaging = messaging ??
            (Firebase.apps.isEmpty ? null : FirebaseMessaging.instance),
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin(),
        _onReceived = onReceived,
        _onTapped = onTapped;

  final FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final NotificationCallback _onReceived;
  final NotificationCallback _onTapped;
  final StreamController<String?> _tokenController =
      StreamController<String?>.broadcast();

  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;
  TokenRegistrationCallback? _tokenRegistrationCallback;
  String? _currentToken;
  bool _initialized = false;

  Stream<String?> get tokenStream => _tokenController.stream;
  String? get currentToken => _currentToken;
  bool get _supportsLocalNotifications =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> initialize() async {
    if (_initialized || Firebase.apps.isEmpty) return;
    _initialized = true;

    await _requestPermissions();
    if (_supportsLocalNotifications) {
      await _initializeLocalNotifications();
    }

    _messageSubscription =
        FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _openedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(_onBackgroundTap);
    _tokenSubscription = _messaging!.onTokenRefresh.listen(_handleToken);

    await refreshToken();

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteTap(initialMessage, NotificationSource.terminated);
    }
  }

  Future<void> _requestPermissions() async {
    await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (!kIsWeb && Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(notificationChannel);
  }

  Future<String?> refreshToken() async {
    final token = await _messaging
        ?.getToken()
        .timeout(_platformCallTimeout, onTimeout: () => null);
    if (token != null) await _handleToken(token);
    return token;
  }

  Future<void> registerTokenWithBackend(
      TokenRegistrationCallback callback) async {
    _tokenRegistrationCallback = callback;
    final token = _currentToken;
    if (token != null) await callback(token);
  }

  Future<void> _handleToken(String token) async {
    _currentToken = token;
    _tokenController.add(token);
    await _tokenRegistrationCallback?.call(token);
  }

  Future<void> subscribeToTopic(String topic) async {
    final messaging = _messaging;
    if (messaging == null) return;
    await messaging.subscribeToTopic(_validateTopic(topic));
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    final messaging = _messaging;
    if (messaging == null) return;
    await messaging.unsubscribeFromTopic(_validateTopic(topic));
  }

  Future<void> subscribeForUser(
      {required String role, required Object userId}) async {
    final normalizedRole = role.toLowerCase();
    if (normalizedRole == 'client') {
      await subscribeToTopic('clients');
    } else if (normalizedRole == 'tasker') {
      await subscribeToTopic('taskers');
      await subscribeToTopic('tasker_$userId');
    } else {
      throw ArgumentError.value(role, 'role', 'Must be client or tasker');
    }
  }

  String _validateTopic(String topic) {
    final value = topic.trim();
    if (!RegExp(r'^[a-zA-Z0-9-_.~%]{1,900}$').hasMatch(value)) {
      throw ArgumentError.value(topic, 'topic', 'Invalid FCM topic name');
    }
    return value;
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final payload = _tryParse(message.data);
    if (payload != null) {
      _onReceived(payload, NotificationSource.foreground);
    }

    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();
    if (!_supportsLocalNotifications || (title == null && body == null)) return;

    await _localNotifications.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title ?? 'Lem3alam',
      body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'lem3alam_high_importance',
          'Important notifications',
          channelDescription: 'Task, message, and payment notifications.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload == null ? null : jsonEncode(payload.toJson()),
    );
  }

  void _onBackgroundTap(RemoteMessage message) =>
      _handleRemoteTap(message, NotificationSource.background);

  void _handleRemoteTap(RemoteMessage message, NotificationSource source) {
    final payload = _tryParse(message.data);
    if (payload != null) _onTapped(payload, source);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final encoded = response.payload;
    if (encoded == null || encoded.isEmpty) return;
    try {
      final json = jsonDecode(encoded);
      if (json is Map<String, dynamic>) {
        _onTapped(NotificationPayload.fromJson(json), NotificationSource.local);
      }
    } on FormatException {
      debugPrint('Ignored malformed local notification payload.');
    }
  }

  NotificationPayload? _tryParse(Map<String, dynamic> data) {
    try {
      return NotificationPayload.fromJson(data);
    } on FormatException catch (error) {
      debugPrint('Ignored malformed FCM payload: $error');
      return null;
    }
  }

  Future<void> dispose() async {
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _tokenSubscription?.cancel();
    await _tokenController.close();
  }
}
