import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/dashboard/application/dashboard_controller.dart';
import 'package:lem3alam_mobile/src/features/dashboard/data/dashboard_api.dart';
import 'package:lem3alam_mobile/src/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/dashboard/domain/dashboard_models.dart';
import 'package:lem3alam_mobile/src/features/dashboard/domain/dashboard_repository.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/tasker_assignments_repository.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/widgets/dashboard_performance.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/widgets/dashboard_stats.dart';

Map<String, dynamic> _data({bool empty = false, num total = 1000.25}) => {
      'user': {'id': 1, 'role': 'tasker'},
      'stats': {
        'active_tasks': empty ? 0 : 2,
        'completed_tasks': empty ? 0 : 5,
        'total_earnings': empty ? 0 : total,
        'rating': 0,
        'pending_tasks': 0,
        'accepted_tasks': 0
      },
      'recent_tasks': [],
      for (final monthly in [false, true])
        monthly ? 'monthly_performance' : 'performance': {
          'earnings': empty
              ? 0
              : monthly
                  ? 500.75
                  : 100.5,
          'tasks_completed': empty
              ? 0
              : monthly
                  ? 5
                  : 1,
          'earnings_change_percent': empty
              ? null
              : monthly
                  ? 25.5
                  : -50,
          'tasks_change_percent': empty ? null : 0,
          'timezone': 'Africa/Casablanca',
          'points': List.generate(
              monthly ? 31 : 7,
              (index) => {
                    'date': DateTime(2026, 8, monthly ? index + 1 : index + 24)
                        .toIso8601String()
                        .substring(0, 10),
                    'day_index': index,
                    'is_future': index >= (monthly ? 27 : 4),
                    'value': empty || index != 1
                        ? 0
                        : monthly
                            ? 500.75
                            : 100.5,
                    'tasks_completed': empty || index != 1
                        ? 0
                        : monthly
                            ? 5
                            : 1,
                  }),
        },
    };

class _Auth extends AuthController {
  _Auth({this.role = 'tasker'});
  final String role;
  @override
  AuthState build() => _state(1);
  AuthState _state(int id) => AuthState(
      status: AuthStatus.authenticated,
      user: User(
          id: id,
          name: 'Tasker $id',
          email: 'test@example.com',
          role: role,
          status: 'active',
          city: 'Rabat'));
  void switchAccount(int id) => state = _state(id);
  void signOut() => state = AuthState.unauthenticated;
}

class _Repo implements DashboardRepository {
  _Repo(this.fetch);
  final Future<DashboardSnapshot> Function() fetch;
  @override
  Future<DashboardSnapshot> fetchDashboard() => fetch();
}

Widget _app(
        {Future<DashboardSnapshot> Function()? load,
        Locale locale = const Locale('en'),
        bool dark = false,
        double scale = 1,
        GlobalKey? capture}) =>
    ProviderScope(
      overrides: [
        taskerAssignmentsProvider.overrideWith((ref) async => []),
        authControllerProvider.overrideWith(_Auth.new),
        dashboardRepositoryProvider.overrideWithValue(
            _Repo(load ?? () async => DashboardSnapshot.fromJson(_data())))
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
          home: RepaintBoundary(key: capture, child: const DashboardScreen())),
    );

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  if (!const bool.fromEnvironment('TASKER_ANALYTICS_SNAPSHOTS')) return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = await Directory('build/tasker_analytics_preview')
        .create(recursive: true);
    await File('${directory.path}/$name.png')
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
      'periods preserve decimals, signed growth, dates and exclude future points',
      () {
    final snapshot = DashboardSnapshot.fromJson(_data());
    expect(snapshot.stats.totalEarnings, 1000.25);
    expect(snapshot.performance.earnings, 100.5);
    expect(snapshot.performance.points.length, 4);
    expect(snapshot.performance.earningsChangePercent, -50);
    expect(snapshot.monthlyPerformance!.earnings, 500.75);
    expect(snapshot.monthlyPerformance!.points.length, 27);
    expect(snapshot.monthlyPerformance!.earningsChangePercent, 25.5);
    expect(
        DashboardSnapshot.fromJson(_data(empty: true))
            .performance
            .earningsChangePercent,
        isNull);
    expect(
        () => DashboardPerformance.fromJson(
            {'points': [], 'earnings': 'NaN', 'tasks_completed': 0}),
        throwsFormatException);
    expect(
        WeeklyPerformancePoint.fromJson({'day_index': 0, 'value': 0})
            .tasksCompleted,
        isNull);
  });

  test('repository rejects a different or missing owner before displaying data',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/v1/'));
    addTearDown(() => dio.close(force: true));
    Map<String, dynamic>? owner = {'id': 2};
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.path, 'tasker/dashboard');
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'success': true,
        'data': {..._data(), 'user': owner}
      }));
    }));
    final repo = DashboardRepositoryImpl(DashboardApi(ApiClient(dio)),
        audience: DashboardAudience.tasker, expectedUserId: 1);
    await expectLater(repo.fetchDashboard(), throwsFormatException);
    owner = null;
    await expectLater(repo.fetchDashboard(), throwsFormatException);
    owner = {'id': 1};
    expect((await repo.fetchDashboard()).performance.earnings, 100.5);
  });

  test('account change clears state and ignores the old accounts late response',
      () async {
    final first = Completer<DashboardSnapshot>();
    final second = Completer<DashboardSnapshot>();
    final requests = <int>[];
    late ProviderContainer container;
    container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      dashboardRepositoryProvider.overrideWithValue(_Repo(() {
        final id = container.read(authControllerProvider).user!.id;
        requests.add(id);
        return id == 1 ? first.future : second.future;
      })),
    ]);
    addTearDown(container.dispose);
    final sub =
        container.listen(dashboardControllerProvider, (previous, next) {});
    addTearDown(sub.close);
    await Future<void>.delayed(Duration.zero);
    (container.read(authControllerProvider.notifier) as _Auth).switchAccount(2);
    expect(container.read(dashboardControllerProvider).hasLoaded, false);
    await Future<void>.delayed(Duration.zero);
    second.complete(DashboardSnapshot.fromJson(_data(total: 22)));
    await Future<void>.delayed(Duration.zero);
    expect(
        container
            .read(dashboardControllerProvider)
            .snapshot
            .stats
            .totalEarnings,
        22);
    first.complete(DashboardSnapshot.fromJson(_data(total: 111)));
    await Future<void>.delayed(Duration.zero);
    expect(
        container
            .read(dashboardControllerProvider)
            .snapshot
            .stats
            .totalEarnings,
        22);
    expect(requests, [1, 2]);
    (container.read(authControllerProvider.notifier) as _Auth).signOut();
    expect(
        container
            .read(dashboardControllerProvider)
            .snapshot
            .stats
            .totalEarnings,
        0);
    expect(container.read(dashboardControllerProvider).hasLoaded, false);
  });

  test('non-tasker accounts never fetch tasker dashboard data', () async {
    var calls = 0;
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(() => _Auth(role: 'client')),
      dashboardRepositoryProvider.overrideWithValue(_Repo(() async {
        calls++;
        return DashboardSnapshot.empty;
      })),
    ]);
    addTearDown(container.dispose);
    final sub =
        container.listen(dashboardControllerProvider, (previous, next) {});
    addTearDown(sub.close);
    await Future<void>.delayed(Duration.zero);
    expect(calls, 0);
  });

  testWidgets(
      'loading and zero activity are distinct and real zero charts remain visible',
      (tester) async {
    final result = Completer<DashboardSnapshot>();
    await tester.pumpWidget(_app(load: () => result.future));
    await tester.pump();
    expect(find.byType(DashboardStatsRow), findsNothing);
    result.complete(DashboardSnapshot.fromJson(_data(empty: true)));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardStatsRow), findsOneWidget);
    expect(find.byType(DashboardPerformanceSection), findsOneWidget);
    expect(
        find.text(
            'You have no recorded earnings or completed tasks in this period.'),
        findsOneWidget);
  });

  testWidgets('switching month changes actual metrics and daily chart data',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('This Week'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('This Week'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('This Month'));
    await tester.pumpAndSettle();
    final section = tester.widget<DashboardPerformanceSection>(
        find.byType(DashboardPerformanceSection));
    expect(section.earningsValue, '500.75 MAD');
    expect(section.tasksCompletedValue, '5');
    expect(section.points.length, 27);
    expect(section.earningsChangePercent, 25.5);
  });

  testWidgets(
      'legacy server does not reuse weekly data for a missing monthly period',
      (tester) async {
    final data = _data()..remove('monthly_performance');
    await tester
        .pumpWidget(_app(load: () async => DashboardSnapshot.fromJson(data)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('This Week'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('This Week'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('This Month'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<DashboardPerformanceSection>(
                find.byType(DashboardPerformanceSection))
            .isAvailable,
        false);
    expect(
        find.text(
            'Analytics for this period are unavailable. Update the server and refresh.'),
        findsOneWidget);
  });

  testWidgets(
      'API errors have a working retry and refresh reloads the dashboard',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(_app(load: () async {
      if (++calls == 1) throw Exception('offline');
      return DashboardSnapshot.fromJson(_data());
    }));
    await tester.pumpAndSettle();
    expect(find.text('Couldn’t load your tasker dashboard'), findsOneWidget);
    expect(find.byType(DashboardPerformanceSection), findsNothing);
    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardPerformanceSection), findsOneWidget);
    final refresh = tester
        .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
        .show();
    await tester.pumpAndSettle();
    await refresh;
    expect(calls, 3);
    expect(tester.takeException(), isNull);
  });

  for (final locale in [
    const Locale('en'),
    const Locale('fr'),
    const Locale('ar')
  ]) {
    for (final dark in [false, true]) {
      testWidgets(
          '${locale.languageCode} dark=$dark tasker analytics fits compact layout',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final key = GlobalKey();
        await tester.pumpWidget(
            _app(locale: locale, dark: dark, scale: 1.15, capture: key));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(DashboardPerformanceSection));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await _capture(
            tester, key, '${locale.languageCode}_${dark ? 'dark' : 'light'}');
      });
    }
  }
}
