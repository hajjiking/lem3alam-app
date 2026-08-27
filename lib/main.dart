import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Cairo'], license);
  });
  runApp(
    ProviderScope(
      observers: const [_ProviderErrorObserver()],
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
