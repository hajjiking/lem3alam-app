import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsProvider = Provider<AppAnalytics>((ref) => const DebugAppAnalytics());

abstract class AppAnalytics {
  const AppAnalytics();

  void track(String name, {Map<String, Object?> properties = const {}});
}

class DebugAppAnalytics extends AppAnalytics {
  const DebugAppAnalytics();

  @override
  void track(String name, {Map<String, Object?> properties = const {}}) {
    if (!kDebugMode) return;
    debugPrint('ANALYTICS $name ${properties.isEmpty ? '' : properties}');
  }
}

