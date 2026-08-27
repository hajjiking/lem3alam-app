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
import 'package:lem3alam_mobile/src/features/admin/data/admin_api.dart';
import 'package:lem3alam_mobile/src/features/admin/data/admin_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/admin/domain/admin_dashboard_models.dart';
import 'package:lem3alam_mobile/src/features/admin/domain/admin_dashboard_summary.dart';
import 'package:lem3alam_mobile/src/features/admin/presentation/admin_dashboard_controller.dart';
import 'package:lem3alam_mobile/src/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:lem3alam_mobile/src/features/admin/presentation/widgets/tasks_overview_chart.dart';
import 'package:lem3alam_mobile/src/features/admin/presentation/widgets/tasks_status_donut.dart';
import 'package:lem3alam_mobile/src/features/admin/presentation/widgets/top_categories_card.dart';
import 'package:lem3alam_mobile/src/features/admin/presentation/widgets/recent_tasks_card.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';

Map<String, dynamic> _data({bool empty = false, int posted = 3}) => {
      'users_count': 3,
      'tasks_count': empty ? 0 : 5,
      'disputes_count': 0,
      'revenue': 900,
      'completed_payments_amount': 120.5,
      'completed_tasks': empty ? 0 : 1,
      'active_tasks': empty ? 0 : 3,
      'analytics': {
        'timezone': 'Africa/Casablanca',
        for (final period in ['weekly_series', 'monthly_series'])
          period: List.generate(
              period == 'weekly_series' ? 7 : 30,
              (index) => {
                    'date': DateTime(2026, 8, 27)
                        .subtract(Duration(
                            days: (period == 'weekly_series' ? 6 : 29) - index))
                        .toIso8601String()
                        .substring(0, 10),
                    'posted': empty
                        ? 0
                        : index == 0
                            ? posted
                            : 0,
                    'started': empty
                        ? 0
                        : index == 1
                            ? 2
                            : 0,
                    'completed': empty
                        ? 0
                        : index == 2
                            ? 1
                            : 0,
                  }),
        'status_counts': [
          for (final status in [
            'open',
            'assigned',
            'in_progress',
            'completed',
            'cancelled'
          ])
            {'status': status, 'count': empty ? 0 : 1}
        ],
        'top_categories': [
          if (!empty)
            {'id': 4, 'name': 'Custom API category', 'count': 5, 'percent': 100}
        ],
        'recent_tasks': [
          if (!empty)
            {
              'id': 83,
              'title': 'Real API task title',
              'customer_name': 'Actual client',
              'status': 'completed',
              'created_at': '2026-08-27T10:00:00Z',
              'primary_image_url': null
            }
        ],
      },
    };

class _Auth extends AuthController {
  @override
  AuthState build() => const AuthState(
      status: AuthStatus.authenticated,
      user: User(
          id: 1,
          name: 'Admin',
          email: 'admin@example.com',
          role: 'admin',
          status: 'active',
          city: 'Rabat'));
}

Widget _app(
        {Locale locale = const Locale('en'),
        bool dark = false,
        double scale = 1,
        GlobalKey? capture,
        Future<AdminDashboardSummary> Function()? load}) =>
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_Auth.new),
        adminDashboardProvider.overrideWith((ref) =>
            load?.call() ??
            Future.value(AdminDashboardSummary.fromJson(_data())))
      ],
      child: MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!),
        home: RepaintBoundary(
            key: capture,
            child: Scaffold(
                body: AdminDashboardScreen(
                    onMenuTap: () {},
                    onNotificationsTap: () {},
                    onProfileTap: () {},
                    onTasksTap: () {}))),
      ),
    );

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  if (!const bool.fromEnvironment('ADMIN_ANALYTICS_SNAPSHOTS')) return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = await Directory('build/admin_analytics_preview')
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

  test('parses actual category names, task IDs, dates, counts and paid totals',
      () {
    final summary = AdminDashboardSummary.fromJson(_data());
    expect(summary.paidVolume, 120.5);
    expect(summary.revenue, 900);
    expect(summary.analytics!.weeklySeries.length, 7);
    expect(summary.analytics!.monthlySeries.length, 30);
    expect(summary.analytics!.weeklySeries.first.posted, 3);
    expect(summary.analytics!.categories.single.name, 'Custom API category');
    expect(summary.analytics!.recentTasks.single.id, 83);
    expect(summary.analytics!.totalTasks, 5);
    expect(
        AdminDashboardSummary.fromJson({'users_count': 3}).analytics, isNull);
  });

  test('rejects malformed analytics rather than fabricating zero values', () {
    for (final field in [
      'weekly_series',
      'monthly_series',
      'status_counts',
      'top_categories',
      'recent_tasks'
    ]) {
      final data = _data();
      (data['analytics'] as Map)[field] = 'not a list';
      expect(() => AdminDashboardSummary.fromJson(data), throwsFormatException);
    }
    for (final count in [-1, 'NaN', 1.5, null]) {
      expect(() => analyticsCount(count), throwsFormatException);
    }
  });

  test('chart scales for empty, small and large platforms', () {
    expect(taskChartGridStep([]), 1);
    expect(
        taskChartGridStep(
            AdminDashboardSummary.fromJson(_data()).analytics!.weeklySeries),
        1);
    expect(
        taskChartGridStep(AdminDashboardSummary.fromJson(_data(posted: 5000))
            .analytics!
            .weeklySeries),
        1250);
  });

  test(
      'admin repository passes the requested locale and parses nested analytics',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/v1/'));
    addTearDown(() => dio.close(force: true));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.uri.path, '/api/v1/admin/dashboard');
      expect(options.queryParameters, {'locale': 'fr'});
      handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true, 'data': _data()}));
    }));
    final summary =
        await AdminRepositoryImpl(AdminApi(ApiClient(dio)), locale: 'fr')
            .fetchDashboard();
    expect(summary.analytics!.recentTasks.single.title, 'Real API task title');
  });

  testWidgets(
      'live analytics replace the placeholder and range selection works',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.textContaining('Detailed analytics will appear'), findsNothing);
    expect(find.byType(TasksOverviewChart), findsOneWidget);
    expect(find.byType(TasksStatusDonut), findsOneWidget);
    expect(find.text('Custom API category'), findsOneWidget);
    expect(find.text('Real API task title'), findsOneWidget);
    await tester.ensureVisible(find.text('Last 7 days'));
    await tester.tap(find.text('Last 7 days'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last 30 days'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TasksOverviewChart>(find.byType(TasksOverviewChart))
            .points
            .length,
        30);
    await tester.ensureVisible(find.text('View chart data'));
    await tester.tap(find.text('View chart data'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Posted: 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty analytics are not confused with unavailable analytics',
      (tester) async {
    await tester.pumpWidget(_app(
        load: () async => AdminDashboardSummary.fromJson(_data(empty: true))));
    await tester.pumpAndSettle();
    expect(find.byType(TasksOverviewChart), findsOneWidget);
    expect(
        find.text('No recorded task activity in this period.'), findsOneWidget);
    expect(find.text('No recent tasks yet.'), findsOneWidget);
    expect(find.byType(AdminRecentTasksCard), findsNothing);
    expect(find.textContaining('Detailed analytics will appear'), findsNothing);
  });

  testWidgets('pull to refresh reloads analytics and waits for data',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(_app(
        load: () async =>
            AdminDashboardSummary.fromJson(_data(posted: ++calls))));
    await tester.pumpAndSettle();
    final refresh = tester
        .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
        .show();
    await tester.pumpAndSettle();
    await refresh;
    expect(calls, 2);
    expect(
        tester
            .widget<TasksOverviewChart>(find.byType(TasksOverviewChart))
            .points
            .first
            .posted,
        2);
  });

  testWidgets('failed request shows retry instead of charts', (tester) async {
    var calls = 0;
    await tester.pumpWidget(_app(load: () async {
      if (++calls == 1) throw Exception('offline');
      return AdminDashboardSummary.fromJson(_data());
    }));
    await tester.pumpAndSettle();
    expect(find.byType(TasksOverviewChart), findsNothing);
    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(TasksOverviewChart), findsOneWidget);
  });

  for (final locale in [
    const Locale('en'),
    const Locale('fr'),
    const Locale('ar')
  ]) {
    for (final dark in [false, true]) {
      testWidgets('compact ${locale.languageCode} dark=$dark analytics layout',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final key = GlobalKey();
        await tester.pumpWidget(
            _app(locale: locale, dark: dark, scale: 1.15, capture: key));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final section in [
          TasksOverviewChart,
          TasksStatusDonut,
          AdminTopCategoriesCard,
          AdminRecentTasksCard
        ]) {
          await tester.ensureVisible(find.byType(section));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await _capture(tester, key,
              '${locale.languageCode}_${dark ? 'dark' : 'light'}_$section');
        }
      });
    }
  }
}
