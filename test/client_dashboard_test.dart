import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/l10n/locale_controller.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/dashboard/application/client_dashboard_controller.dart';
import 'package:lem3alam_mobile/src/features/dashboard/data/dashboard_api.dart';
import 'package:lem3alam_mobile/src/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/dashboard/domain/dashboard_models.dart';
import 'package:lem3alam_mobile/src/features/dashboard/domain/dashboard_repository.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/client_dashboard_screen.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/widgets/dashboard_bottom_navigation.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/widgets/dashboard_stats.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/widgets/dashboard_tasks.dart';
import 'package:lem3alam_mobile/src/routing/app_router.dart';

// Fixtures stay in tests. Production always reads the authenticated dashboard API.
Map<String, dynamic> _payload() => {
      'stats': {
        'active_tasks': 3,
        'completed_tasks': 24,
        'pending_tasks': 2,
        'accepted_tasks': 1
      },
      'recent_tasks': [
        for (final entry in [
          (81, 'fresh', 'open'),
          (82, 'accepted', 'assigned'),
          (83, 'completed', 'completed'),
          (84, 'fresh', 'cancelled')
        ])
          {
            'id': entry.$1,
            'title': 'API task ${entry.$1}',
            'category': {'name': 'Home repairs'},
            'city': 'Rabat',
            'dashboard_status': entry.$2,
            'status': entry.$3,
            'budget': '120.50',
            'created_at': DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String()
          },
      ],
    };

class _Auth extends AuthController {
  _Auth([this.role = 'client']);
  final String role;
  @override
  AuthState build() => AuthState(
      status: AuthStatus.authenticated,
      user: User(
          id: 7,
          name: 'Amina Amrani',
          email: 'test@example.com',
          role: role,
          status: 'active',
          city: 'Rabat'));
  void switchAccount() => state = const AuthState(
      status: AuthStatus.authenticated,
      user: User(
          id: 8,
          name: 'Next Client',
          email: 'next@example.com',
          role: 'client',
          status: 'active',
          city: 'Rabat'));
}

class _Locale extends LocaleController {
  _Locale(this.locale);
  final Locale locale;
  @override
  Locale build() => locale;
}

class _Repository implements DashboardRepository {
  _Repository(this.fetch);
  final Future<DashboardSnapshot> Function() fetch;
  @override
  Future<DashboardSnapshot> fetchDashboard() => fetch();
}

Widget _app(DashboardRepository repository,
    {Locale locale = const Locale('en'),
    bool dark = false,
    String role = 'client',
    double scale = 1,
    GlobalKey? captureKey}) {
  return ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(() => _Auth(role)),
        localeControllerProvider.overrideWith(() => _Locale(locale)),
        dashboardRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!),
        home: RepaintBoundary(
          key: captureKey,
          child: Builder(builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: const RoleDashboardScreen(),
              bottomNavigationBar: captureKey == null
                  ? null
                  : DashboardBottomNavigation(
                      selectedIndex: 0,
                      homeLabel: l10n.home,
                      tasksLabel: l10n.tasks,
                      messagesLabel: l10n.dashboardMessages,
                      earningsLabel: l10n.clientDashboardPayments,
                      profileLabel: l10n.dashboardProfile,
                      postTaskLabel: l10n.dashboardPostTask,
                      onSelected: (index) {},
                    ),
            );
          }),
        ),
      ));
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  if (!const bool.fromEnvironment('CLIENT_SNAPSHOTS')) return;
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
  });
  await tester.pump();
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = await Directory('build/client_dashboard_preview')
        .create(recursive: true);
    await File('${dir.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Cairo')
          ..addFont(rootBundle.load('assets/fonts/Cairo.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });

  test(
      'API mapping preserves decimal budgets and omits unavailable percentages',
      () {
    final snapshot = DashboardSnapshot.fromJson(_payload());
    expect(snapshot.stats.activeTasks, 3);
    expect(snapshot.stats.successRate, isNull);
    expect(snapshot.tasks.first.price, 120.5);
    expect(
        clientDashboardTasks(snapshot, DashboardTaskFilter.pending)
            .map((t) => t.id),
        [81]);
    expect(
        clientDashboardTasks(snapshot, DashboardTaskFilter.accepted)
            .map((t) => t.id),
        [82]);
    expect(
        clientDashboardTasks(snapshot, DashboardTaskFilter.completed)
            .map((t) => t.id),
        [83]);
    for (final value in [null, 'bad', 'NaN', -1, 101]) {
      expect(
          DashboardStats.fromJson({'success_rate': value}).successRate, isNull);
    }
    expect(DashboardStats.fromJson({'success_rate': '95.5'}).successRate, 95.5);
    expect(DashboardTask.fromJson({'id': 1}).hasCreatedAt, isFalse);
  });

  test('repository uses dashboard endpoint and rejects malformed data',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com/public/api/v1/'));
    addTearDown(() => dio.close(force: true));
    Object response = {'success': true, 'data': _payload()};
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.uri.path, '/public/api/v1/dashboard');
      handler.resolve(
          Response(requestOptions: options, data: response, statusCode: 200));
    }));
    final repository = DashboardRepositoryImpl(DashboardApi(ApiClient(dio)));
    expect((await repository.fetchDashboard()).stats.completedTasks, 24);
    for (final invalid in [
      {},
      {'data': {}},
      {'success': false, 'data': _payload()},
      {
        'data': {'stats': {}, 'recent_tasks': []}
      }
    ]) {
      response = invalid;
      await expectLater(repository.fetchDashboard(),
          throwsA(anyOf(isA<FormatException>(), isA<ApiException>())));
    }
  });

  test('account changes fetch a new snapshot', () async {
    var calls = 0;
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      localeControllerProvider.overrideWith(() => _Locale(const Locale('en'))),
      dashboardRepositoryProvider.overrideWithValue(_Repository(() async {
        calls++;
        return DashboardSnapshot.fromJson(_payload());
      })),
    ]);
    addTearDown(container.dispose);
    final subscription =
        container.listen(clientDashboardProvider, (previous, next) {});
    addTearDown(subscription.close);
    await container.read(clientDashboardProvider.future);
    (container.read(authControllerProvider.notifier) as _Auth).switchAccount();
    await container.read(clientDashboardProvider.future);
    expect(calls, 2);
  });

  testWidgets('loading does not fabricate zero statistics', (tester) async {
    final completer = Completer<DashboardSnapshot>();
    await tester.pumpWidget(_app(_Repository(() => completer.future)));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(DashboardDetailStatCard), findsNothing);
    completer.complete(DashboardSnapshot.empty);
    await tester.pumpAndSettle();
    expect(find.text('No tasks yet. Post your first task to get started.'),
        findsOneWidget);
    expect(find.byType(DashboardDetailStatCard), findsNWidgets(3));
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('failed API request has a working retry', (tester) async {
    var calls = 0;
    await tester.pumpWidget(_app(_Repository(() async {
      if (++calls == 1) throw Exception('offline');
      return DashboardSnapshot.fromJson(_payload());
    })));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardDetailStatCard), findsNothing);
    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byType(DashboardDetailStatCard), findsNWidgets(3));
  });

  testWidgets('filters show API tasks without cancelled or sample tasks',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1536));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
        _app(_Repository(() async => DashboardSnapshot.fromJson(_payload()))));
    await tester.pumpAndSettle();
    expect(find.text('API task 81'), findsOneWidget);
    expect(find.text('120.5 MAD'), findsOneWidget);
    expect(find.text('API task 84'), findsNothing);
    expect(find.text('Repair washing machine'), findsNothing);
    expect(find.text('Online'), findsNothing);
    await tester.tap(find.text('Accepted (1)'));
    await tester.pumpAndSettle();
    expect(find.text('API task 82'), findsOneWidget);
    expect(find.text('API task 81'), findsNothing);
    await tester.tap(find.descendant(
        of: find.byType(DashboardFilterBar), matching: find.text('Completed')));
    await tester.pumpAndSettle();
    expect(find.text('API task 83'), findsOneWidget);
  });

  testWidgets('taskers keep their existing dashboard', (tester) async {
    await tester.pumpWidget(
        _app(_Repository(() async => DashboardSnapshot.empty), role: 'tasker'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(ClientDashboardScreen), findsNothing);
  });

  for (final size in [const Size(360, 900), const Size(1024, 1536)]) {
    for (final locale in [
      const Locale('en'),
      const Locale('fr'),
      const Locale('ar')
    ]) {
      for (final dark in [false, true]) {
        testWidgets('${size.width} ${locale.languageCode} dark=$dark layout',
            (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final key = GlobalKey();
          await tester.pumpWidget(_app(
              _Repository(() async => DashboardSnapshot.fromJson(_payload())),
              locale: locale,
              dark: dark,
              scale: size.width < 500 ? 1.2 : 1,
              captureKey: key));
          await tester.pumpAndSettle();
          expect(
              Directionality.of(
                  tester.element(find.byType(ClientDashboardScreen))),
              locale.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr);
          expect(tester.takeException(), isNull);
          await _capture(tester, key,
              '${size.width.toInt()}_${locale.languageCode}_${dark ? 'dark' : 'light'}');
          await tester.scrollUntilVisible(
              find.byType(DashboardTaskCard).first, 250);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await _capture(tester, key,
              '${size.width.toInt()}_${locale.languageCode}_${dark ? 'dark' : 'light'}_tasks');
          await tester.scrollUntilVisible(
              find
                  .text(AppLocalizations.of(
                          tester.element(find.byType(ClientDashboardScreen)))!
                      .dashboardPostTask)
                  .first,
              250);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('task cards and promo navigate to real routes', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1536));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          builder: (context, state) => const ClientDashboardScreen()),
      GoRoute(
          path: '/tasks',
          name: AppRouteNames.tasks,
          builder: (context, state) => const Text('All tasks destination')),
      GoRoute(
          path: '/tasks/create',
          name: AppRouteNames.taskCreate,
          builder: (context, state) => const Text('Create destination')),
      GoRoute(
          path: '/tasks/:id',
          name: AppRouteNames.taskDetail,
          builder: (context, state) =>
              Text('Details ${state.pathParameters['id']}')),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_Auth.new),
          localeControllerProvider
              .overrideWith(() => _Locale(const Locale('en'))),
          dashboardRepositoryProvider.overrideWithValue(
              _Repository(() async => DashboardSnapshot.fromJson(_payload()))),
        ],
        child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.light(),
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('API task 81'));
    await tester.pumpAndSettle();
    expect(find.text('Details 81'), findsOneWidget);
    router.go('/');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Post Task'));
    await tester.tap(find.text('Post Task'));
    await tester.pumpAndSettle();
    expect(find.text('Create destination'), findsOneWidget);
  });

  testWidgets('client navigation uses raised post task in the center',
      (tester) async {
    var selected = -1;
    await tester.binding.setSurfaceSize(const Size(360, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
            bottomNavigationBar: DashboardBottomNavigation(
                selectedIndex: 0,
                homeLabel: 'Home',
                tasksLabel: 'Tasks',
                messagesLabel: 'Messages',
                earningsLabel: 'Payments',
                profileLabel: 'Profile',
                postTaskLabel: 'Post Task',
                onSelected: (index) => selected = index))));
    await tester.tap(find.text('Post Task'));
    expect(selected, 2);
    expect(find.text('Profile'), findsNothing);
    expect(find.text('Payments'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
