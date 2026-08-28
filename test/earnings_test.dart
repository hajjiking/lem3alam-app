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
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/core/l10n/locale_controller.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/earnings/application/earnings_controller.dart';
import 'package:lem3alam_mobile/src/features/earnings/data/earnings_repository.dart';
import 'package:lem3alam_mobile/src/features/earnings/domain/earnings_models.dart';
import 'package:lem3alam_mobile/src/features/earnings/domain/fee_calculator.dart';
import 'package:lem3alam_mobile/src/features/earnings/presentation/earnings_screen.dart';
import 'package:lem3alam_mobile/src/features/earnings/presentation/earnings_summary_card.dart';
import 'package:lem3alam_mobile/src/features/earnings/presentation/earnings_category_donut.dart';
import 'package:lem3alam_mobile/src/features/earnings/presentation/earnings_overview_chart.dart';
import 'package:lem3alam_mobile/src/features/earnings/presentation/recent_transactions_card.dart';
import 'package:lem3alam_mobile/src/features/earnings/presentation/transaction_row.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/widgets/dashboard_bottom_navigation.dart';
import 'package:lem3alam_mobile/src/features/messages/application/conversations_controller.dart';
import 'package:lem3alam_mobile/src/presentation/splash/splash_controller.dart';
import 'package:lem3alam_mobile/src/routing/app_router.dart';

AuthState _identity([int id = 20, String role = 'tasker']) => AuthState(
    status: AuthStatus.authenticated,
    user: User(
        id: id,
        name: 'Mohammed',
        email: 'test@example.com',
        role: role,
        status: 'active',
        city: 'Rabat'));

class _Auth extends AuthController {
  _Auth([this.role = 'tasker']);
  final String role;
  @override
  AuthState build() => _identity(20, role);
  void change(int id) => state = _identity(id);
}

class _Ready extends SplashController {
  @override
  SplashState build() =>
      const SplashState(isReady: true, targetLocation: '/earnings');
}

class _Locale extends LocaleController {
  @override
  Locale build() => const Locale('en');
}

Map<String, dynamic> _record(int id,
        {String bucket = 'current',
        String gross = '200.00',
        String fee = '20.00',
        String net = '180.00',
        int category = 1}) =>
    {
      'id': '${bucket == 'estimate' ? 'task' : 'payment'}:$id',
      'task_id': id,
      'task_title': 'Repair washing machine $id',
      'category_id': category,
      'category_name': category == 1 ? 'Home Maintenance' : 'Plumbing',
      'bucket': bucket,
      'date': bucket == 'previous' ? '2026-07-15' : '2026-08-15',
      'status': bucket == 'estimate' ? 'in_progress' : 'completed',
      'gross_amount': gross,
      if (bucket != 'estimate') ...{'platform_fee': fee, 'net_amount': net},
    };
Map<String, dynamic> _metadata(EarningsPeriod period, {int owner = 20}) => {
      'tasker_id': owner,
      'currency': 'MAD',
      'period': period.apiValue,
      'start_date': period == EarningsPeriod.lastMonth
          ? '2026-07-01'
          : period == EarningsPeriod.thisYear
              ? '2026-01-01'
              : '2026-08-01',
      'end_date':
          period == EarningsPeriod.lastMonth ? '2026-07-31' : '2026-08-28',
      'as_of': '2026-08-28T12:00:00Z',
      'estimate_fee_rate': '0.05',
      'available_balance': null,
      'stats': {
        'completed_tasks': 3,
        'previous_completed_tasks': 1,
        'in_progress_count': 1,
        'average_rating': 4.8,
        'review_count': 12,
        'total_jobs_all_time': 5
      },
    };

class _Api extends ApiClient {
  _Api() : super(Dio());
  int owner = 20;
  List<Map<String, dynamic>> records = [
    _record(1),
    _record(2, category: 2),
    _record(3, bucket: 'previous')
  ];
  List<Map<String, dynamic>> estimates = [_record(4, bucket: 'estimate')];
  final requests = <Map<String, dynamic>>[];
  Future<void> Function()? beforeGet;
  @override
  Future<T> getJson<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    expect(path, 'tasker/earnings');
    final query = queryParameters!;
    requests.add(query);
    await beforeGet?.call();
    final page = query['page'] as int;
    final period =
        EarningsPeriod.values.firstWhere((p) => p.apiValue == query['period']);
    return {
      'success': true,
      'data': {
        ..._metadata(period, owner: owner),
        'estimates': estimates,
        'ledger': {
          'current_page': page,
          'last_page': records.isEmpty ? 1 : records.length,
          'data': records.isEmpty
              ? []
              : [
                  {
                    ...records[page - 1],
                    if (period == EarningsPeriod.lastMonth)
                      'date': records[page - 1]['bucket'] == 'previous'
                          ? '2026-06-15'
                          : '2026-07-15'
                  }
                ],
          'total': records.length
        }
      }
    } as T;
  }
}

EarningsRepository _repo(_Api api,
        {AuthState Function()? auth, Future<void> Function()? expire}) =>
    EarningsRepository(api, auth ?? _identity, expire ?? () async {});
final _capture = GlobalKey();

class _DeferredRepository extends EarningsRepository {
  _DeferredRepository() : super(_Api(), _identity, () async {});
  final requests =
      <({EarningsPeriod period, Completer<EarningsLedger> response})>[];

  @override
  Future<EarningsLedger> load(EarningsPeriod period) {
    final response = Completer<EarningsLedger>();
    requests.add((period: period, response: response));
    return response.future;
  }
}

Future<void> _pump(WidgetTester tester, _Api api,
    {String language = 'en', bool wide = false, bool dark = false}) async {
  tester.view.physicalSize = Size(wide ? 1100 : 360, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_Auth.new),
        localeControllerProvider.overrideWith(_Locale.new),
        earningsRepositoryProvider.overrideWithValue(_repo(api)),
      ],
      child: MaterialApp(
          locale: Locale(language),
          theme: dark ? AppTheme.dark() : AppTheme.light(),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: RepaintBoundary(
              key: _capture, child: const Scaffold(body: EarningsScreen())))));
  await tester.pumpAndSettle();
}

Future<void> _screenshot(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('EARNINGS_SCREENSHOTS')) return;
  await tester.runAsync(() async {
    final boundary =
        _capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/earnings-previews').create(recursive: true);
    await File('build/earnings-previews/$name.png')
        .writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (const bool.fromEnvironment('EARNINGS_SCREENSHOTS')) {
      await (FontLoader('Cairo')
            ..addFont(rootBundle.load('assets/fonts/Cairo.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    }
  });
  test(
      'all ledger pages use same as-of, then reconcile summary/chart/categories without estimates',
      () async {
    final api = _Api();
    final data = await _repo(api).load(EarningsPeriod.thisMonth);
    final view = EarningsView(data, const FeeCalculator());
    expect(api.requests, hasLength(3));
    expect(api.requests[1]['as_of'], '2026-08-28T12:00:00Z');
    expect(view.summary.gross, 40000);
    expect(view.summary.fee, 4000);
    expect(view.summary.net, 36000);
    expect(view.transactions, hasLength(3));
    expect(view.deltaPercent, 100);
    expect(view.points.last.net, view.summary.net);
    expect(view.categoryEarnings.fold(0, (n, c) => n + c.amounts.net),
        view.summary.net);
    expect(view.categoryEarnings.fold(0, (n, c) => n + c.percent), 100);
    expect(view.transactions.last.amounts(view.calculator).net, 19000);
  });
  test('rounding is per transaction; category remainder sums to 100', () {
    final records = [
      for (var i = 1; i <= 3; i++)
        TransactionRecord.fromJson(
            _record(i, gross: '0.10', fee: '0.01', net: '0.09', category: i))
    ];
    final view = EarningsView(
        EarningsLedger.fromJson(_metadata(EarningsPeriod.thisMonth), records),
        const FeeCalculator());
    expect(view.summary.net, 27);
    expect(view.summary.fee, 3);
    expect(view.categoryEarnings.map((c) => c.percent).reduce((a, b) => a + b),
        100);
    expect(view.deltaPercent, isNull);
  });
  test('empty period does not invent earnings, rates of change or balance', () {
    final view = EarningsView(
        EarningsLedger.fromJson(_metadata(EarningsPeriod.thisMonth), []),
        const FeeCalculator());
    expect(view.summary.net, 0);
    expect(view.deltaPercent, null);
    expect(view.categoryEarnings, isEmpty);
    expect(view.points.every((p) => p.net == 0), true);
    expect(view.ledger.availableBalance, null);
  });
  test(
      'rejects foreign accounts, clients, stale data and stale 401 session expiry',
      () async {
    final api = _Api()..owner = 30;
    await expectLater(_repo(api).load(EarningsPeriod.thisMonth),
        throwsA(isA<ApiException>()));
    await expectLater(
        _repo(api, auth: () => _identity(20, 'client'))
            .load(EarningsPeriod.thisMonth),
        throwsA(isA<ApiException>()));
    var auth = _identity();
    api.beforeGet = () async {
      auth = _identity(30);
    };
    await expectLater(
        _repo(api, auth: () => auth).load(EarningsPeriod.thisMonth),
        throwsA(isA<ApiException>()));
    auth = _identity();
    var expired = false;
    api.beforeGet = () async {
      auth = _identity(30);
      throw const ApiException(statusCode: 401, message: 'err_unauthorized');
    };
    await expectLater(
        _repo(api,
            auth: () => auth,
            expire: () async {
              expired = true;
            }).load(EarningsPeriod.thisMonth),
        throwsA(isA<ApiException>()));
    expect(expired, false);
  });
  testWidgets('tasker Earnings route uses active nav and no post-task FAB',
      (tester) async {
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      splashControllerProvider.overrideWith(_Ready.new),
      localeControllerProvider.overrideWith(_Locale.new),
      earningsRepositoryProvider.overrideWithValue(_repo(_Api())),
      conversationsControllerProvider.overrideWith(() => _Conversations()),
    ]);
    addTearDown(container.dispose);
    final router = container.read(goRouterProvider)
      ..goNamed(AppRouteNames.earnings);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.light(),
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates)));
    await tester.pumpAndSettle();
    final nav = tester.widget<DashboardBottomNavigation>(
        find.byType(DashboardBottomNavigation));
    expect(nav.selectedIndex, 3);
    expect(nav.postTaskLabel, null);
    expect(find.byType(EarningsScreen), findsOneWidget);
    expect(tester.takeException(), null);
  });
  test('late period responses cannot overwrite the selected period', () async {
    final repository = _DeferredRepository();
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      localeControllerProvider.overrideWith(_Locale.new),
      earningsRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    container.listen(earningsControllerProvider, (_, __) {});
    await container.pump();
    container
        .read(earningsPeriodProvider.notifier)
        .select(EarningsPeriod.lastMonth);
    await container.pump();
    expect(repository.requests, hasLength(2));
    repository.requests[1].response.complete(
        EarningsLedger.fromJson(_metadata(EarningsPeriod.lastMonth), []));
    await container.read(earningsControllerProvider.future);
    repository.requests[0].response.complete(EarningsLedger.fromJson(
        _metadata(EarningsPeriod.thisMonth),
        [TransactionRecord.fromJson(_record(1))]));
    await container.pump();
    final view = container.read(earningsControllerProvider).requireValue;
    expect(view.ledger.period, EarningsPeriod.lastMonth);
    expect(view.summary.net, 0);
  });
  test('account switching resets the period and reloads the earnings',
      () async {
    final repository = _DeferredRepository();
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      localeControllerProvider.overrideWith(_Locale.new),
      earningsRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    container
        .read(earningsPeriodProvider.notifier)
        .select(EarningsPeriod.lastMonth);
    container.listen(earningsControllerProvider, (_, __) {});
    await container.pump();
    repository.requests.single.response.complete(
        EarningsLedger.fromJson(_metadata(EarningsPeriod.lastMonth), []));
    await container.read(earningsControllerProvider.future);
    (container.read(authControllerProvider.notifier) as _Auth).change(30);
    await container.pump();
    expect(container.read(earningsPeriodProvider), EarningsPeriod.thisMonth);
    expect(container.read(earningsControllerProvider).isLoading, true);
    expect(repository.requests.last.period, EarningsPeriod.thisMonth);
    repository.requests.last.response.complete(EarningsLedger.fromJson(
        _metadata(EarningsPeriod.thisMonth, owner: 30), []));
    final view = await container.read(earningsControllerProvider.future);
    expect(view.ledger.taskerId, 30);
    expect(view.summary.net, 0);
  });
  testWidgets('both selectors share period state and refetch the API',
      (tester) async {
    final api = _Api();
    await _pump(tester, api);
    await tester
        .tap(find.byType(DropdownButtonFormField<EarningsPeriod>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last Month').last);
    await tester.pumpAndSettle();
    expect(api.requests.last['period'], 'last_month');
    final container =
        ProviderScope.containerOf(tester.element(find.byType(EarningsScreen)));
    expect(container.read(earningsPeriodProvider), EarningsPeriod.lastMonth);
    await tester.ensureVisible(find.byType(EarningsOverviewChart));
    await tester.pumpAndSettle();
    final chartSelector = find.descendant(
        of: find.byType(EarningsOverviewChart),
        matching: find.byType(DropdownButtonFormField<EarningsPeriod>));
    expect(
        tester
            .widget<DropdownButtonFormField<EarningsPeriod>>(chartSelector)
            .initialValue,
        EarningsPeriod.lastMonth);
    await tester.tap(chartSelector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('This Year').last);
    await tester.pumpAndSettle();
    expect(container.read(earningsPeriodProvider), EarningsPeriod.thisYear);
    expect(api.requests.last['period'], 'this_year');
    expect(tester.takeException(), null);
  });
  testWidgets(
      'API failures and inconsistent money produce explicit retry, not fake totals',
      (tester) async {
    final api = _Api()
      ..beforeGet = () async {
        throw const ApiException(statusCode: 500, message: 'err_server');
      };
    await _pump(tester, api);
    expect(find.byType(EarningsSummaryCard), findsNothing);
    api.beforeGet = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(EarningsSummaryCard), findsOneWidget);
    api.records = [_record(1, fee: '20.00', net: '190.00')];
    final container =
        ProviderScope.containerOf(tester.element(find.byType(EarningsScreen)));
    container.invalidate(earningsControllerProvider);
    await tester.pumpAndSettle();
    expect(find.byType(EarningsSummaryCard), findsNothing);
  });
  for (final language in ['en', 'fr', 'ar']) {
    for (final wide in [false, true]) {
      testWidgets(
          '$language ${wide ? 'wide' : 'phone'} layout with real-data fixtures',
          (tester) async {
        await _pump(tester, _Api(),
            language: language, wide: wide, dark: language == 'ar');
        expect(tester.takeException(), null);
        await _screenshot(
            tester, '$language-${wide ? 'wide' : 'phone'}-summary');
        await tester.ensureVisible(find.byType(EarningsOverviewChart));
        await tester.pumpAndSettle();
        expect(tester.takeException(), null);
        await _screenshot(tester, '$language-${wide ? 'wide' : 'phone'}-chart');
        await tester.ensureVisible(find.byType(EarningsCategoryDonut));
        await tester.pumpAndSettle();
        expect(tester.takeException(), null);
        await tester.ensureVisible(find.byType(RecentTransactionsCard));
        await tester.pumpAndSettle();
        expect(find.byType(TransactionRow), findsNWidgets(3));
        expect(tester.takeException(), null);
        await _screenshot(
            tester, '$language-${wide ? 'wide' : 'phone'}-transactions');
      });
    }
  }
}

class _Conversations extends ConversationsController {
  @override
  Future<ConversationsState> build() async => const ConversationsState([], {});
}
