import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/features/notifications/application/notification_providers.dart';
import 'src/features/notifications/data/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run `flutterfire configure` and, when generated, initialize with
  // DefaultFirebaseOptions.currentPlatform here. Native apps configured with
  // google-services.json/GoogleService-Info.plist can use the default call.
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } on FirebaseException catch (error) {
    // Keeps local/dev builds usable until Firebase platform files are added.
    // Production builds should always contain valid Firebase configuration.
    debugPrint('Firebase initialization skipped: ${error.message}');
  }

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Cairo'], license);
  });
  final container = ProviderContainer(
    observers: const [_ProviderErrorObserver()],
  );
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.initialize();

  // Wire this to the authenticated backend endpoint used by your API:
  // await notificationService.registerTokenWithBackend((token) async {
  //   await container.read(apiClientProvider).postJson(
  //     '/devices/fcm-token',
  //     data: {'token': token},
  //   );
  // });
  // After authentication, subscribe with:
  // await notificationService.subscribeForUser(
  //   role: user.role,
  //   userId: user.id,
  // );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const Lem3alamApp(),
    ),
  );
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
