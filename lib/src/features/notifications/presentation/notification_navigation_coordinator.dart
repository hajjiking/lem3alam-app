import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/splash/splash_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../application/notification_center_controller.dart';
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
    extends ConsumerState<NotificationNavigationCoordinator>
    with WidgetsBindingObserver {
  bool _navigationScheduled = false;
  String? _activeAccountKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<NotificationState>(
      notificationStateProvider,
      (previous, next) {
        _scheduleNavigation();
        final incoming = next.lastReceived;
        if (incoming != null && incoming != previous?.lastReceived) {
          ref
              .read(notificationCenterProvider.notifier)
              .recordIncoming(incoming.payload);
        }
      },
    );
    ref.listen<AuthState>(
      authControllerProvider,
      (_, next) {
        _scheduleNavigation();
        _syncAccount(next);
      },
    );
    ref.listen<SplashState>(
        splashControllerProvider, (_, __) => _scheduleNavigation());
    // Also handles a cold-start tap that arrived before this listener mounted.
    _scheduleNavigation();
    _syncAccount(ref.read(authControllerProvider));
    return widget.child;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final auth = ref.read(authControllerProvider);
    if (auth.status == AuthStatus.authenticated &&
        (auth.user?.isClient == true || auth.user?.isTasker == true)) {
      ref.read(notificationCenterProvider.notifier).refreshIfStale();
    }
  }

  void _syncAccount(AuthState auth) {
    final user = auth.user;
    if (auth.status != AuthStatus.authenticated || user == null) {
      if (_activeAccountKey != null) {
        _activeAccountKey = null;
        ref.read(notificationCenterProvider.notifier).clear();
      }
      return;
    }
    if (!user.isClient && !user.isTasker) return;
    final key = '${user.id}:${user.role}';
    if (_activeAccountKey == key) return;
    _activeAccountKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _activeAccountKey == key) {
        ref.read(notificationCenterProvider.notifier).bootstrap();
      }
    });
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
