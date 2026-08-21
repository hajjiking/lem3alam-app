import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/auth_state.dart';
import '../presentation/splash/splash_controller.dart';

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) => _scheduleNotify(),
    );
    _ref.listen<SplashState>(
      splashControllerProvider,
      (previous, next) => _scheduleNotify(),
    );
  }

  final Ref _ref;
  bool _notifyScheduled = false;

  void _scheduleNotify() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  AuthState get authState => _ref.read(authControllerProvider);
  SplashState get splashState => _ref.read(splashControllerProvider);
}
