import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/earnings/data/cash_payments_repository.dart';
import 'package:lem3alam_mobile/src/features/earnings/presentation/cash_payments_panel.dart';

AuthState _identity([int id = 20, String role = 'tasker']) => AuthState(
    status: AuthStatus.authenticated,
    user: User(
        id: id,
        name: 'Tasker',
        email: 'test@example.com',
        role: role,
        status: 'active',
        city: 'Rabat'));

class _Auth extends AuthController {
  @override
  AuthState build() => _identity();
  void change(int id) => state = _identity(id);
}

Map<String, dynamic> _cash(int id, {int owner = 20, bool canConfirm = true}) =>
    {
      'task_id': id,
      'tasker_id': owner,
      'task_title': 'Repair faucet $id',
      'amount': canConfirm ? '450.00' : null,
      'currency': 'MAD',
      'can_confirm': canConfirm,
    };

class _Api extends ApiClient {
  _Api() : super(Dio());
  final records = <Map<String, dynamic>>[_cash(7)];
  final gets = <Map<String, dynamic>>[];
  final posts = <Object?>[];
  Completer<void>? response;
  bool fail = false;
  Future<void> Function()? onGet;
  @override
  Future<T> getJson<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    expect(path, 'tasker/cash-payments');
    gets.add(queryParameters!);
    await onGet?.call();
    final page = queryParameters['page'] as int;
    return {
      'success': true,
      'data': {
        'data': records.isEmpty ? [] : [records[page - 1]],
        'current_page': page,
        'last_page': records.isEmpty ? 1 : records.length
      }
    } as T;
  }

  @override
  Future<T> postJson<T>(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    expect(path, 'tasks/7/confirm-cash');
    posts.add(data);
    await response?.future;
    if (fail) throw const ApiException(statusCode: 500, message: 'err_server');
    records.clear();
    return {
      'success': true,
      'data': {'status': 'completed'}
    } as T;
  }
}

Future<void> _pump(WidgetTester tester, _Api api,
    {String language = 'en', double scale = 1}) async {
  tester.view.physicalSize = const Size(360, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_Auth.new),
        apiClientProvider.overrideWithValue(api),
      ],
      child: MaterialApp(
          locale: Locale(language),
          theme: language == 'ar' ? AppTheme.dark() : AppTheme.light(),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!),
          home: const Scaffold(
              body: SafeArea(
                  child: SingleChildScrollView(child: CashPaymentsPanel()))))));
  await tester.pumpAndSettle();
}

void main() {
  test(
      'repository paginates, verifies owner, rejects clients and stale account responses',
      () async {
    final api = _Api()..records.add(_cash(8));
    var auth = _identity();
    var expired = false;
    final repo = CashPaymentsRepository(api, () => auth, () async {
      expired = true;
    });
    expect(await repo.load(), hasLength(2));
    expect(api.gets.last['page'], 2);
    api.records[0] = _cash(7, owner: 30);
    await expectLater(repo.load(), throwsA(isA<ApiException>()));
    auth = _identity(20, 'client');
    await expectLater(repo.confirm(CashPayment.fromJson(_cash(7))),
        throwsA(isA<ApiException>()));
    expect(api.posts, isEmpty);
    auth = _identity();
    api.onGet = () async {
      auth = _identity(30);
      throw const ApiException(statusCode: 401, message: 'err_unauthorized');
    };
    await expectLater(repo.load(), throwsA(isA<ApiException>()));
    expect(expired, false);
  });
  testWidgets(
      'cash confirmation shows exact amount, can cancel, prevents double submission and refreshes',
      (tester) async {
    final api = _Api()..response = Completer<void>();
    await _pump(tester, api);
    await tester.tap(find.text('Confirm cash received'));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('received MAD450.00 in cash for Repair faucet 7'),
        findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(api.posts, isEmpty);
    await tester.tap(find.text('Confirm cash received'));
    await tester.pumpAndSettle();
    await tester
        .tap(find.widgetWithText(FilledButton, 'Confirm cash received').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(api.posts, [
      {'amount': '450.00'}
    ]);
    final button = tester.widget<FilledButton>(
        find.byWidgetPredicate((widget) => widget is FilledButton));
    expect(button.onPressed, null);
    api.response!.complete();
    await tester.pumpAndSettle();
    expect(api.posts, hasLength(1));
    expect(find.byType(CashPaymentCard), findsNothing);
    expect(api.gets.length, greaterThan(1));
    expect(
        find.text('Cash receipt confirmed. Your earnings have been updated.'),
        findsOneWidget);
    expect(tester.takeException(), null);
  });
  testWidgets('failed confirmation stays unpaid and allows an explicit retry',
      (tester) async {
    final api = _Api()..fail = true;
    await _pump(tester, api);
    for (final fail in [true, false]) {
      api.fail = fail;
      await tester.tap(find.text('Confirm cash received'));
      await tester.pumpAndSettle();
      await tester
          .tap(find.widgetWithText(FilledButton, 'Confirm cash received').last);
      await tester.pumpAndSettle();
      if (fail) expect(find.byType(CashPaymentCard), findsOneWidget);
    }
    expect(api.posts, hasLength(2));
    expect(find.byType(CashPaymentCard), findsNothing);
    expect(tester.takeException(), null);
  });
  testWidgets('switching account while dialog is open prevents the write',
      (tester) async {
    final api = _Api();
    await _pump(tester, api);
    final container = ProviderScope.containerOf(
        tester.element(find.byType(CashPaymentsPanel)));
    await tester.tap(find.text('Confirm cash received'));
    await tester.pumpAndSettle();
    (container.read(authControllerProvider.notifier) as _Auth).change(30);
    await tester.pumpAndSettle();
    await tester
        .tap(find.widgetWithText(FilledButton, 'Confirm cash received').last);
    await tester.pumpAndSettle();
    expect(api.posts, isEmpty);
    expect(tester.takeException(), null);
  });
  testWidgets('missing agreed amount never offers a confirmation button',
      (tester) async {
    final api = _Api()..records[0] = _cash(7, canConfirm: false);
    await _pump(tester, api);
    expect(find.text('Confirm cash received'), findsNothing);
    expect(find.textContaining('agreed final amount'), findsOneWidget);
  });
  for (final locale in ['en', 'fr', 'ar']) {
    testWidgets(
        '$locale cash panel and dialog fit compact screens with large text',
        (tester) async {
      await _pump(tester, _Api(), language: locale, scale: 1.6);
      final button =
          find.byWidgetPredicate((widget) => widget is FilledButton).first;
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(tester.takeException(), null);
    });
  }
}
