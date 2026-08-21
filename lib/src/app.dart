import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';

import 'core/l10n/locale_controller.dart';
import 'core/ui/app_theme.dart';
import 'routing/app_router.dart';

class Lem3alamApp extends ConsumerWidget {
  const Lem3alamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: AppLocalizations.of(context)?.appName ?? 'lem3alam',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final activeLocale = Localizations.maybeLocaleOf(context) ?? locale;
        final textDirection = activeLocale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
        return Directionality(textDirection: textDirection, child: child ?? const SizedBox.shrink());
      },
      routerConfig: router,
    );
  }
}
