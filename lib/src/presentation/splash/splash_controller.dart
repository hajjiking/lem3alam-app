import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/auth_state.dart';

final splashControllerProvider =
    NotifierProvider<SplashController, SplashState>(SplashController.new);

class SplashState {
  const SplashState({
    this.isReady = false,
    this.targetLocation,
  });

  final bool isReady;
  final String? targetLocation;

  SplashState copyWith({
    bool? isReady,
    String? targetLocation,
  }) {
    return SplashState(
      isReady: isReady ?? this.isReady,
      targetLocation: targetLocation ?? this.targetLocation,
    );
  }
}

class SplashController extends Notifier<SplashState> {
  static const _minimumSplashDuration = Duration(seconds: 2);
  var _started = false;

  @override
  SplashState build() {
    // Start the launch sequence only once when the splash provider is first read.
    if (!_started) {
      _started = true;
      Future.microtask(_prepareLaunch);
    }

    return const SplashState();
  }

  Future<void> _prepareLaunch() async {
    // Keep the splash visible long enough to feel premium while auth bootstraps.
    await Future.wait<void>([
      Future<void>.delayed(_minimumSplashDuration),
      _waitForAuthBootstrap(),
    ]);

    if (!ref.mounted) return;

    final auth = ref.read(authControllerProvider);
    final targetLocation = switch (auth.status) {
      AuthStatus.authenticated =>
        auth.user?.isAdmin == true ? '/admin' : '/dashboard',
      _ => '/login',
    };

    state = state.copyWith(
      isReady: true,
      targetLocation: targetLocation,
    );
  }

  Future<void> _waitForAuthBootstrap() async {
    // Wait until the auth controller finishes resolving the stored session.
    while (ref.mounted) {
      final auth = ref.read(authControllerProvider);
      if (auth.status != AuthStatus.unknown) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 80));
    }
  }
}
