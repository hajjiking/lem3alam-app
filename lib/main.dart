import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/features/notifications/application/notification_providers.dart';
import 'src/features/notifications/data/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Cairo'], license);
  });
  final container = ProviderContainer(
    observers: const [_ProviderErrorObserver()],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const Lem3alamApp(),
    ),
  );

  // Permission prompts and FCM token retrieval can wait on platform services
  // or the network. Start them only after Flutter has rendered its first frame
  // so notification availability can never block application startup.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeNotifications(container));
  });
}

Future<void> _initializeNotifications(ProviderContainer container) async {
  try {
    // Run `flutterfire configure`. Native configurations can use this default
    // call; otherwise pass DefaultFirebaseOptions.currentPlatform here.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp().timeout(const Duration(seconds: 10));
    }

    final notificationService = container.read(notificationServiceProvider);
    await notificationService.initialize();

    // Wire registerTokenWithBackend() to the authenticated backend endpoint,
    // then call subscribeForUser(role: user.role, userId: user.id).
  } on Object catch (error, stackTrace) {
    // Firebase is optional at launch: configuration/network failures must not
    // prevent authentication, routing, or the splash screen from completing.
    debugPrint('Notification initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

base class _ProviderErrorObserver extends ProviderObserver {
  const _ProviderErrorObserver();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint(
      '[ProviderScope.observers] Provider ${context.provider.name ?? context.provider.runtimeType} failed',
      wrapWidth: 1024,
    );
    debugPrint('$error');
    debugPrint('$stackTrace');
  }
}
