import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/splash/splash_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../application/notification_router.dart';
import '../application/notification_state.dart';

class NotificationNavigationCoordinator extends ConsumerStatefulWidget {
  const NotificationNavigationCoordinator({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<NotificationNavigationCoordinator> createState() =>
      _NotificationNavigationCoordinatorState();
}

class _NotificationNavigationCoordinatorState
    extends ConsumerState<NotificationNavigationCoordinator> {
  bool _navigationScheduled = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<NotificationState>(
      notificationStateProvider,
      (_, __) => _scheduleNavigation(),
    );
    ref.listen<AuthState>(
        authControllerProvider, (_, __) => _scheduleNavigation());
    ref.listen<SplashState>(
        splashControllerProvider, (_, __) => _scheduleNavigation());
    // Also handles a cold-start tap that arrived before this listener mounted.
    _scheduleNavigation();
    return widget.child;
  }

  void _scheduleNavigation() {
    if (_navigationScheduled) return;
    _navigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationScheduled = false;
      if (!mounted) return;

      final event = ref.read(notificationStateProvider).pendingTap;
      if (event == null) return;

      final auth = ref.read(authControllerProvider);
      final splash = ref.read(splashControllerProvider);
      if (!splash.isReady || auth.status != AuthStatus.authenticated) return;

      final role = auth.user?.role;
      if (role == null) return;

      ref.read(notificationRouterProvider).route(
            event.payload,
            currentRole: role,
          );
      // Unsupported or cross-role payloads are deliberately discarded too.
      ref.read(notificationStateProvider.notifier).consumeTap();
    });
  }
}
