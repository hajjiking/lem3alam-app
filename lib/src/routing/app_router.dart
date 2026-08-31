import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../core/l10n/l10n.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/auth_state.dart';
import '../features/admin/presentation/admin_home_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/dashboard/application/client_dashboard_controller.dart';
import '../features/dashboard/application/dashboard_controller.dart';
import '../features/dashboard/presentation/client_dashboard_screen.dart';
import '../features/dashboard/presentation/tasker_categories_screen.dart';
import '../features/dashboard/presentation/widgets/dashboard_bottom_navigation.dart';
import '../features/location/presentation/map_picker_screen.dart';
import '../features/location/presentation/nearby_providers_map_screen.dart';
import '../features/messages/presentation/messages_screen.dart';
import '../features/messages/application/conversations_controller.dart';
import '../features/earnings/presentation/earnings_screen.dart';
import '../features/payments/presentation/client_payments_screen.dart';
import '../features/payments/application/client_payments_controller.dart';
import '../features/earnings/application/earnings_controller.dart';
import '../features/earnings/data/cash_payments_repository.dart';
import '../features/taskers/presentation/tasker_profile_screen.dart';
import '../features/taskers/presentation/tasker_reviews_screen.dart';
import '../features/tasks/presentation/task_detail_screen.dart';
import '../features/tasks/presentation/task_form_screen.dart';
import '../features/tasks/presentation/nearby_tasks_screen.dart';
import '../features/tasks/presentation/task_list_screen.dart';
import '../presentation/splash/splash_screen.dart';
import 'router_notifier.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _tasksBranchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'tasksBranch');
final _dashboardBranchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'dashboardBranch');
final _messagesBranchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'messagesBranch');
final _earningsBranchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'earningsBranch');
final _paymentsBranchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'paymentsBranch');

abstract class AppRouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'register';
  static const adminHome = 'adminHome';

  static const tasks = 'tasks';
  static const taskCreate = 'taskCreate';
  static const taskDetail = 'taskDetail';
  static const taskEdit = 'taskEdit';

  static const dashboard = 'dashboard';
  static const dashboardCategories = 'dashboardCategories';
  static const nearbyProvidersMap = 'nearbyProvidersMap';
  static const nearbyTasks = 'nearbyTasks';
  static const mapPicker = 'mapPicker';

  static const taskerProfile = 'taskerProfile';
  static const taskerReviews = 'taskerReviews';
  static const messages = 'messages';
  static const messageThread = 'messageThread';
  static const earnings = 'earnings';
  static const payments = 'payments';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = notifier.authState;
      final splash = notifier.splashState;

      final location = state.uri.path;
      final isSplash = location == '/splash';
      final isAuthRoute = location == '/login' || location == '/register';
      final isAdminHome = location == '/admin';
      final isTaskList = location == '/tasks';
      final isTaskDetail = RegExp(r'^/tasks/\d+$').hasMatch(location);
      final isNearbyTasks = location == '/nearby-tasks';
      final isClientNotificationTask = RegExp(r'^/client/tasks/[^/]+$').hasMatch(location);
      final isTaskerNotificationRequest = RegExp(r'^/tasker/requests/[^/]+$').hasMatch(location);
      final isTaskerNotificationEarning = RegExp(r'^/tasker/earnings/[^/]+$').hasMatch(location);
      final isNotificationChat = RegExp(r'^/chat/[^/]+$').hasMatch(location);
      final isTaskerProfile = RegExp(r'^/taskers/\d+$').hasMatch(location);
      final isTaskerReviews = RegExp(r'^/taskers/\d+/reviews$').hasMatch(location);
      final isPublicRoute = isAuthRoute || isTaskerProfile || isTaskerReviews;
      final isProtectedTaskRoute = location == '/tasks/create' || RegExp(r'^/tasks/\d+/edit$').hasMatch(location);
      final isTaskDataRoute = isTaskList || isTaskDetail || isNearbyTasks || isProtectedTaskRoute ||
          isClientNotificationTask || isTaskerNotificationRequest;
      final isClient = auth.user?.role == 'client';
      final isTasker = auth.user?.role == 'tasker';
      final isAdmin = auth.user?.isAdmin == true;
      // #region debug-point D:router-redirect
      (() { try { final client = HttpClient(); client.postUrl(Uri.parse('http://127.0.0.1:7778/event')).then((req) { req.headers.contentType = ContentType.json; req.write(jsonEncode({'sessionId': 'tasker-tasks-crash', 'runId': 'pre-fix', 'hypothesisId': 'D', 'location': 'app_router.dart:71', 'msg': '[DEBUG] router redirect evaluated', 'data': {'location': location, 'authStatus': auth.status.name, 'role': auth.user?.role, 'splashReady': splash.isReady, 'targetLocation': splash.targetLocation}, 'ts': DateTime.now().millisecondsSinceEpoch})); return req.close(); }).then((res) => res.drain<void>()).whenComplete(client.close).catchError((_) {}); } catch (_) {} })();
      // #endregion

      if (!splash.isReady) {
        return isSplash ? null : '/splash';
      }

      if (isSplash) {
        return splash.targetLocation ?? '/login';
      }

      if (auth.status == AuthStatus.unauthenticated) {
        if (isTaskDataRoute) return '/login';
        if (isPublicRoute) return null;
        return '/login';
      }

      if (auth.status == AuthStatus.authenticated) {
        if (isAuthRoute) return isAdmin ? '/admin' : '/dashboard';
        if (isAdmin && !isAdminHome && location == '/dashboard') {
          return '/admin';
        }
        if (isProtectedTaskRoute && !isClient) return '/tasks';
        if (isNearbyTasks && !isTasker) return '/tasks';
        if (isClientNotificationTask && !isClient) return '/dashboard';
        if ((isTaskerNotificationRequest || isTaskerNotificationEarning) && !isTasker) {
          return '/dashboard';
        }
        if (isNotificationChat && !isClient && !isTasker) return '/admin';
        if (location.startsWith('/messages') && !isClient && !isTasker) return '/admin';
        if (location.startsWith('/earnings') && !isTasker) return isAdmin ? '/admin' : '/dashboard';
        if (location.startsWith('/payments') && !isClient) return isAdmin ? '/admin' : '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRouteNames.splash,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            child: const SplashScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/login',
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: AppRouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: AppRouteNames.adminHome,
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/nearby',
        name: AppRouteNames.nearbyProvidersMap,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const NearbyProvidersMapScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/nearby-tasks',
        name: AppRouteNames.nearbyTasks,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const NearbyTasksScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/map/pick',
        name: AppRouteNames.mapPicker,
        pageBuilder: (context, state) {
          final initial = state.extra;
          return CustomTransitionPage(
            key: state.pageKey,
            child: MapPickerScreen(initialLocation: initial is LatLng ? initial : null),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/client/tasks/:targetId',
        builder: (context, state) => TaskDetailScreen(
          taskId: int.tryParse(state.pathParameters['targetId'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/chat/:targetId',
        builder: (context, state) => MessagesScreen(
          selected: (
            contactId: int.tryParse(state.pathParameters['targetId'] ?? '') ?? 0,
            taskId: int.tryParse(state.uri.queryParameters['task_id'] ?? ''),
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/tasker/requests/:targetId',
        builder: (context, state) => TaskDetailScreen(
          taskId: int.tryParse(state.pathParameters['targetId'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/tasker/earnings/:targetId',
        builder: (context, state) => const EarningsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _AppShell(
          navigationShell: navigationShell,
          location: state.uri.path,
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey: _tasksBranchNavigatorKey,
            routes: [
              GoRoute(
                path: '/tasks',
                name: AppRouteNames.tasks,
                pageBuilder: (context, state) => const NoTransitionPage(child: TaskListScreen()),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: AppRouteNames.taskCreate,
                    pageBuilder: (context, state) {
                      final qp = state.uri.queryParameters;
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: TaskFormScreen(
                          prefillTitle: qp['prefill_title'],
                          prefillDescription: qp['prefill_description'],
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: animation.drive(
                              Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
                                  .chain(CurveTween(curve: Curves.easeOutCubic)),
                            ),
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                      );
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    name: AppRouteNames.taskDetail,
                    pageBuilder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: TaskDetailScreen(taskId: id),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
                            child: child,
                          );
                        },
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: AppRouteNames.taskEdit,
                        pageBuilder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return CustomTransitionPage(
                            key: state.pageKey,
                            child: TaskFormScreen(editTaskId: id),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: animation.drive(
                                  Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
                                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                                ),
                                child: FadeTransition(opacity: animation, child: child),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: '/taskers/:id',
                name: AppRouteNames.taskerProfile,
                pageBuilder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: TaskerProfileScreen(taskerId: id),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
                        child: child,
                      );
                    },
                  );
                },
                routes: [
                  GoRoute(
                    path: 'reviews',
                    name: AppRouteNames.taskerReviews,
                    pageBuilder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: TaskerReviewsScreen(taskerId: id),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: animation.drive(
                              Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
                                  .chain(CurveTween(curve: Curves.easeOutCubic)),
                            ),
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _dashboardBranchNavigatorKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                name: AppRouteNames.dashboard,
                pageBuilder: (context, state) => const NoTransitionPage(child: RoleDashboardScreen()),
                routes: [
                  GoRoute(
                    path: 'categories',
                    name: AppRouteNames.dashboardCategories,
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const TaskerCategoriesScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: animation.drive(
                              Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
                                  .chain(CurveTween(curve: Curves.easeOutCubic)),
                            ),
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(navigatorKey: _messagesBranchNavigatorKey, routes: [
            GoRoute(path: '/messages', name: AppRouteNames.messages,
              pageBuilder: (context, state) => const NoTransitionPage(child: MessagesScreen()),
              routes: [GoRoute(path: ':peerId', name: AppRouteNames.messageThread,
                builder: (context, state) => MessagesScreen(selected: (
                  contactId: int.tryParse(state.pathParameters['peerId'] ?? '') ?? 0,
                  taskId: int.tryParse(state.uri.queryParameters['task_id'] ?? ''),
                )))])
          ]),
          StatefulShellBranch(navigatorKey: _earningsBranchNavigatorKey, routes: [
            GoRoute(path: '/earnings', name: AppRouteNames.earnings,
              pageBuilder: (context, state) => const NoTransitionPage(child: EarningsScreen())),
          ]),
          StatefulShellBranch(navigatorKey: _paymentsBranchNavigatorKey, routes: [
            GoRoute(path: '/payments', name: AppRouteNames.payments,
              pageBuilder: (context, state) => const NoTransitionPage(child: ClientPaymentsScreen())),
          ]),
        ],
      ),
    ],
  );
});

class _AppShell extends ConsumerWidget {
  const _AppShell({required this.navigationShell, required this.location});

  final StatefulNavigationShell navigationShell;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final clientPaymentsPage = auth.user?.isClient == true && navigationShell.currentIndex == 4;

    final currentNavigator = switch (navigationShell.currentIndex) {
      0 => _tasksBranchNavigatorKey.currentState,
      2 => _messagesBranchNavigatorKey.currentState,
      3 => _earningsBranchNavigatorKey.currentState,
      4 => _paymentsBranchNavigatorKey.currentState,
      _ => _dashboardBranchNavigatorKey.currentState,
    };
    final currentBranchCanPop = currentNavigator?.canPop() ?? false;
    final canPop = currentBranchCanPop || navigationShell.currentIndex == 0;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: DashboardBottomNavigation(
          selectedIndex: auth.user?.isClient == true && location == '/tasks/create'
              ? 2 : location.startsWith('/taskers/') && auth.user?.isClient != true
              ? 4
              : navigationShell.currentIndex == 2 ? (auth.user?.isClient == true ? 3 : 2)
              : navigationShell.currentIndex == 3 || navigationShell.currentIndex == 4 ? 3
              : (navigationShell.currentIndex == 1 ? 0 : 1),
          unreadMessageCount: auth.user?.isClient == true || auth.user?.isTasker == true
              ? ref.watch(conversationsControllerProvider).asData?.value.unreadCount ?? 0 : 0,
          homeLabel: l10n.home,
          tasksLabel: l10n.tasks,
          messagesLabel: l10n.dashboardMessages,
          earningsLabel: auth.user?.isClient == true ? l10n.clientDashboardPayments : l10n.dashboardEarnings,
          profileLabel: l10n.dashboardProfile,
          postTaskLabel: auth.user?.isClient == true && !clientPaymentsPage ? l10n.dashboardPostTask : null,
          onSelected: (index) {
            if (auth.user?.isClient == true) {
              if (clientPaymentsPage && index >= 2) {
                if (index == 2) navigationShell.goBranch(2);
                if (index == 3) ref.invalidate(clientPaymentsControllerProvider);
                if (index == 4) _showUnavailable(context, l10n.dashboardProfile);
                return;
              }
              if (index == 2) {
                context.goNamed(AppRouteNames.taskCreate);
                return;
              }
              if (index == 3) {
                navigationShell.goBranch(2);
                return;
              }
              if (index == 4) {
                ref.invalidate(clientPaymentsControllerProvider);
                navigationShell.goBranch(4);
                return;
              }
              if (index == 0) ref.invalidate(clientDashboardProvider);
            }
            switch (index) {
              case 0:
                if (auth.user?.isTasker == true) ref.invalidate(dashboardControllerProvider);
                if (auth.status != AuthStatus.authenticated) {
                  context.goNamed(AppRouteNames.login);
                  return;
                }
                navigationShell.goBranch(
                  1,
                  initialLocation: navigationShell.currentIndex == 1,
                );
                return;
              case 1:
                navigationShell.goBranch(
                  0,
                  initialLocation: navigationShell.currentIndex == 0,
                );
                return;
              case 2:
                navigationShell.goBranch(2);
                return;
              case 3:
                ref.invalidate(cashPaymentsProvider);
                ref.invalidate(earningsControllerProvider);
                navigationShell.goBranch(3);
                return;
              case 4:
                if (auth.user?.isTasker == true) {
                  context.goNamed(
                    AppRouteNames.taskerProfile,
                    pathParameters: {'id': auth.user!.id.toString()},
                  );
                } else {
                  _showUnavailable(context, l10n.dashboardProfile);
                }
                return;
            }
          },
        ),
      ),
    );
  }

  void _showUnavailable(BuildContext context, String feature) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10n.dashboardFeatureUnavailable(feature))),
      );
  }
}
