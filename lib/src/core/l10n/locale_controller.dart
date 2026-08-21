import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../networking/dio_provider.dart';

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);

class LocaleController extends Notifier<Locale> {
  static const _key = 'app_locale';
  static const _supported = {'ar', 'en', 'fr'};
  var _loaded = false;

  @override
  Locale build() {
    if (!_loaded) {
      _loaded = true;
      Future.microtask(load);
    }
    return _normalizeLocale(WidgetsBinding.instance.platformDispatcher.locale);
  }

  Future<void> load() async {
    final storage = ref.read(secureStorageProvider);
    final code = await storage.read(key: _key);
    if (code == null || code.isEmpty) return;
    if (!ref.mounted) return;
    state = _normalizeLocale(Locale(code));
  }

  Future<void> setLocale(Locale locale) async {
    final normalized = _normalizeLocale(locale);
    state = normalized;
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: _key, value: normalized.languageCode);
  }

  Locale _normalizeLocale(Locale locale) {
    final code = locale.languageCode.toLowerCase();
    if (_supported.contains(code)) {
      return Locale(code);
    }
    return const Locale('ar');
  }
}
