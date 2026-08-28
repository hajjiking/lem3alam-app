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
import 'package:lem3alam_mobile/src/core/l10n/locale_controller.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/core/ui/money_overview_chart.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/widgets/dashboard_bottom_navigation.dart';
import 'package:lem3alam_mobile/src/features/earnings/domain/earnings_models.dart';
import 'package:lem3alam_mobile/src/features/messages/application/conversations_controller.dart';
import 'package:lem3alam_mobile/src/features/payments/application/client_payments_controller.dart';
import 'package:lem3alam_mobile/src/features/payments/data/client_payments_repository.dart';
import 'package:lem3alam_mobile/src/features/payments/domain/client_payments.dart';
import 'package:lem3alam_mobile/src/features/payments/presentation/client_payments_screen.dart';
import 'package:lem3alam_mobile/src/presentation/splash/splash_controller.dart';
import 'package:lem3alam_mobile/src/routing/app_router.dart';

AuthState identity([int id = 20, String role = 'client']) => AuthState(
    status: AuthStatus.authenticated,
    user: User(
        id: id,
        name: 'Amina',
        email: 'test@example.com',
        role: role,
        status: 'active',
        city: 'Rabat'));

class Auth extends AuthController {
  @override
  AuthState build() => identity();
  void change(int id) => state = identity(id);
}

class Ready extends SplashController {
  @override
  SplashState build() =>
      const SplashState(isReady: true, targetLocation: '/payments');
}

class TestLocale extends LocaleController {
  @override
  Locale build() => const Locale('en');
}

class Conversations extends ConversationsController {
  @override
  Future<ConversationsState> build() async => const ConversationsState([], {});
}

Map<String, dynamic> record(int id,
        {String status = 'completed', String amount = '200.00'}) =>
    {
      'id': id,
      'payer_id': 20,
      'task_id': id,
      'task_title': 'Repair washing machine $id',
      'category_id': id,
      'category_name': id == 1 ? 'Home Maintenance' : 'Plumbing',
      'amount': amount,
      'platform_fee': '10.00',
      'net_amount': '190.00',
      'currency': 'MAD',
      'status': status,
      'method': 'cash',
      'date': '2026-08-20',
      'date_type': status == 'completed' ? 'paid' : 'created',
    };
Map<String, dynamic> metadata(EarningsPeriod period) => {
      'client_id': 20,
      'currency': 'MAD',
      'period': period.apiValue,
      'as_of': '2026-08-28T12:00:00Z',
      'timezone': 'UTC',
      'start_date': period == EarningsPeriod.lastMonth
          ? '2026-07-01'
          : period == EarningsPeriod.thisYear
              ? '2026-01-01'
              : '2026-08-01',
      'end_date':
          period == EarningsPeriod.lastMonth ? '2026-07-31' : '2026-08-28',
      'wallet_balance': null,
      'remaining_budget': null,
      'refunds': null,
      'payment_methods': null,
      'stats': {
        'tasks_posted': 18,
        'completed_tasks': 12,
        'previous_completed_tasks': 9,
        'in_progress': 2,
        'total_spent_all_time': '2450.00',
        'undated_completed_count': 0
      },
    };

class Api extends ApiClient {
  Api() : super(Dio());
  List<Map<String, dynamic>> records = [
    record(1),
    record(2, amount: '150.00'),
    record(3, status: 'pending'),
    record(4, status: 'refunded'),
    record(5, status: 'failed'),
    record(6, status: 'disputed')
  ];
  final requests = <Map<String, dynamic>>[];
  Future<void> Function()? before;
  int owner = 20;
  @override
  Future<T> getJson<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    expectSync(path, 'client/payments');
    final q = queryParameters!;
    requests.add(q);
    await before?.call();
    final page = q['page'] as int;
    final period =
        EarningsPeriod.values.firstWhere((p) => p.apiValue == q['period']);
    return {
      'success': true,
      'data': {
        ...metadata(period),
        'client_id': owner,
        'ledger': {
          'current_page': page,
          'last_page': records.isEmpty ? 1 : records.length,
          'total': records.length,
          'data': records.isEmpty
              ? []
              : [
                  {
                    ...records[page - 1],
                    if (period == EarningsPeriod.lastMonth) 'date': '2026-07-20'
                  }
                ]
        }
      }
    } as T;
  }
}

ClientPaymentsRepository repo(Api api,
        {AuthState Function()? auth, Future<void> Function()? expire}) =>
    ClientPaymentsRepository(api, auth ?? identity, expire ?? () async {});

class Deferred extends ClientPaymentsRepository {
  Deferred() : super(Api(), identity, () async {});
  final responses = <Completer<ClientPaymentsView>>[];
  @override
  Future<ClientPaymentsView> load(EarningsPeriod period) {
    final c = Completer<ClientPaymentsView>();
    responses.add(c);
    return c.future;
  }
}

final capture = GlobalKey();
Future<void> pumpPage(WidgetTester tester, Api api,
    {String lang = 'en', double width = 360, double scale = 1}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(Auth.new),
        localeControllerProvider.overrideWith(TestLocale.new),
        clientPaymentsRepositoryProvider.overrideWithValue(repo(api))
      ],
      child: MaterialApp(
          locale: Locale(lang),
          theme: lang == 'ar' ? AppTheme.dark() : AppTheme.light(),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (c, child) => MediaQuery(
              data: MediaQuery.of(c)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!),
          home: RepaintBoundary(
              key: capture,
              child: const Scaffold(body: ClientPaymentsScreen())))));
  await tester.pumpAndSettle();
}

Future<void> screenshot(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('PAYMENTS_SCREENSHOTS')) return;
  await tester.runAsync(() async {
    final image = await (capture.currentContext!.findRenderObject()!
            as RenderRepaintBoundary)
        .toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/payments-previews').create(recursive: true);
    await File('build/payments-previews/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (const bool.fromEnvironment('PAYMENTS_SCREENSHOTS')) {
      await (FontLoader('Cairo')
            ..addFont(rootBundle.load('assets/fonts/Cairo.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    }
  });
  test('gross spending, chart, categories reconcile; all pages use as-of',
      () async {
    final api = Api();
    final view = await repo(api).load(EarningsPeriod.thisMonth);
    expect(view.totalSpent, 35000);
    expect(view.allTimeSpent, 245000);
    expect(view.records, hasLength(6));
    expect(api.requests, hasLength(6));
    expect(api.requests[1]['as_of'], '2026-08-28T12:00:00Z');
    expect(view.points.last.value, 35000);
    expect(view.categories.fold(0, (n, c) => n + c.amount), 35000);
    expect(view.categories.fold(0, (n, c) => n + c.percent), 100);
    final yearly = await repo(api).load(EarningsPeriod.thisYear);
    expect(yearly.points, hasLength(8));
    expect(yearly.points.last.value, 35000);
  });
  test('empty and only-unpaid ledgers have no spending', () async {
    final api = Api()..records = [];
    expect((await repo(api).load(EarningsPeriod.thisMonth)).totalSpent, 0);
    api.records = [record(1, status: 'pending')];
    final view = await repo(api).load(EarningsPeriod.thisMonth);
    expect(view.totalSpent, 0);
    expect(view.categories, isEmpty);
  });
  test('rejects foreign payer, role, period and negative amounts', () async {
    final api = Api()..owner = 21;
    await expectLater(
        repo(api).load(EarningsPeriod.thisMonth), throwsA(isA<ApiException>()));
    await expectLater(
        repo(Api(), auth: () => identity(20, 'tasker'))
            .load(EarningsPeriod.thisMonth),
        throwsA(isA<ApiException>()));
    final foreign = Api()
      ..records = [
        {...record(1), 'payer_id': 21}
      ];
    await expectLater(repo(foreign).load(EarningsPeriod.thisMonth),
        throwsA(isA<ApiException>()));
    expect(() => ClientPayment.fromJson(record(1, amount: '-2.00')),
        throwsFormatException);
    expect(
        () => ClientPaymentsView(metadata(EarningsPeriod.lastMonth),
            [ClientPayment.fromJson(record(1))]),
        throwsFormatException);
  });
  test(
      'stale account responses and stale 401 never expose or expire new account',
      () async {
    var auth = identity();
    var expired = false;
    final api = Api()
      ..before = () async {
        auth = identity(21);
      };
    await expectLater(
        repo(api, auth: () => auth).load(EarningsPeriod.thisMonth),
        throwsA(isA<ApiException>()));
    auth = identity();
    api.before = () async {
      auth = identity(21);
      throw const ApiException(statusCode: 401, message: 'expired');
    };
    await expectLater(
        repo(api,
            auth: () => auth,
            expire: () async {
              expired = true;
            }).load(EarningsPeriod.thisMonth),
        throwsA(isA<ApiException>()));
    expect(expired, false);
  });
  test(
      'late periods cannot replace selected data and account change resets period',
      () async {
    final r = Deferred();
    final c = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(Auth.new),
      localeControllerProvider.overrideWith(TestLocale.new),
      clientPaymentsRepositoryProvider.overrideWithValue(r)
    ]);
    addTearDown(c.dispose);
    c.listen(clientPaymentsControllerProvider, (_, __) {});
    await c.pump();
    c
        .read(clientPaymentsPeriodProvider.notifier)
        .select(EarningsPeriod.lastMonth);
    await c.pump();
    r.responses[1]
        .complete(ClientPaymentsView(metadata(EarningsPeriod.lastMonth), []));
    await c.read(clientPaymentsControllerProvider.future);
    r.responses[0]
        .complete(ClientPaymentsView(metadata(EarningsPeriod.thisMonth), []));
    await c.pump();
    expect(c.read(clientPaymentsControllerProvider).requireValue.period,
        EarningsPeriod.lastMonth);
    (c.read(authControllerProvider.notifier) as Auth).change(21);
    await c.pump();
    expect(c.read(clientPaymentsPeriodProvider), EarningsPeriod.thisMonth);
  });
  testWidgets('client route active Payments navigation without post-task FAB',
      (tester) async {
    final c = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(Auth.new),
      splashControllerProvider.overrideWith(Ready.new),
      localeControllerProvider.overrideWith(TestLocale.new),
      clientPaymentsRepositoryProvider.overrideWithValue(repo(Api())),
      conversationsControllerProvider.overrideWith(Conversations.new)
    ]);
    addTearDown(c.dispose);
    final router = c.read(goRouterProvider)..goNamed(AppRouteNames.payments);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
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
    expect(nav.earningsLabel, 'Payments');
    expect(find.byType(ClientPaymentsScreen), findsOneWidget);
    expect(tester.takeException(), null);
  });
  testWidgets(
      'period selectors sync, unsupported actions explain, history opens',
      (tester) async {
    final api = Api();
    await pumpPage(tester, api);
    final selectors = find.byType(DropdownButtonFormField<EarningsPeriod>);
    tester
        .widget<DropdownButtonFormField<EarningsPeriod>>(selectors.first)
        .onChanged!(EarningsPeriod.lastMonth);
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
        tester.element(find.byType(ClientPaymentsScreen)));
    await container.read(clientPaymentsControllerProvider.future);
    await tester.pumpAndSettle();
    expect(
        tester
            .widgetList<DropdownButtonFormField<EarningsPeriod>>(selectors)
            .every((w) => w.initialValue == EarningsPeriod.lastMonth),
        true);
    await tester.ensureVisible(find.text('Add Funds').first);
    await tester.tap(find.text('Add Funds').first);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Unavailable').last, findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('View All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View All'));
    await tester.pumpAndSettle();
    expect(find.text('All Payments'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add New Card'));
    await tester.pumpAndSettle();
    final requestCount = api.requests.length;
    await tester.tap(find.text('Add New Card'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(api.requests.length, requestCount);
    expect(tester.takeException(), null);
  });
  testWidgets('failed API shows retry without fabricated totals',
      (tester) async {
    final api = Api()
      ..before = () async {
        throw const ApiException(message: 'unavailable', statusCode: 500);
      };
    await pumpPage(tester, api);
    expect(find.byType(PaymentsContent), findsNothing);
    expect(find.text('Could not load your payments. Please retry.'),
        findsOneWidget);
    api.before = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentsContent), findsOneWidget);
  });
  for (final lang in ['en', 'fr', 'ar']) {
    for (final width in [360.0, 1100.0]) {
      testWidgets('$lang $width responsive layout', (tester) async {
        await pumpPage(tester, Api(), lang: lang, width: width);
        expect(tester.takeException(), null);
        await screenshot(tester, '$lang-$width-summary');
        await tester.ensureVisible(find.byType(MoneyOverviewChart));
        await tester.pumpAndSettle();
        expect(tester.takeException(), null);
        await screenshot(tester, '$lang-$width-chart');
        await tester.ensureVisible(find.byType(PaymentRow).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), null);
        await screenshot(tester, '$lang-$width-history');
      });
    }
  }
  testWidgets('large Arabic text stays within mobile layout', (tester) async {
    await pumpPage(tester, Api(), lang: 'ar', scale: 1.6);
    expect(tester.takeException(), null);
    await tester.ensureVisible(find.byType(PaymentRow).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
  });
}
