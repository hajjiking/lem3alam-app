import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/tasks/data/tasks_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/task.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/tasks_repository.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/task_detail_screen.dart';

class _Auth extends AuthController {
  @override
  AuthState build() => const AuthState(
      status: AuthStatus.authenticated,
      user: User(
          id: 20,
          name: 'Tasker',
          email: 'test@example.com',
          role: 'tasker',
          status: 'active',
          city: 'Rabat'));
}

class _Repo implements TasksRepository {
  int submissions = 0;
  int details = 0;
  TaskApplicationPayload? payload;
  Future<void> Function() result = () async {};
  @override
  Future<Task> getById(int id) async {
    details++;
    return Task.fromJson(
        {'id': id, 'client_id': 10, 'title': 'Repair sink', 'status': 'open'});
  }

  @override
  Future<void> apply(
      {required int taskId, required TaskApplicationPayload payload}) {
    submissions++;
    this.payload = payload;
    return result();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PopObserver extends NavigatorObserver {
  int pops = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pops++;
  }
}

Future<void> _open(WidgetTester tester, _Repo repo,
    {NavigatorObserver? observer}) async {
  await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_Auth.new),
        tasksRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
          navigatorObservers: [if (observer != null) observer],
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const TaskDetailScreen(taskId: 19))));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Apply'));
  await tester.tap(find.text('Apply'));
  await tester.pumpAndSettle();
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'I can repair this sink tomorrow.');
  await tester.enterText(fields.at(1), '120,50');
  await tester.enterText(fields.at(2), '2 hours');
}

Future<void> _submit(WidgetTester tester) async {
  final context = tester.element(find.byType(Form));
  final label = AppLocalizations.of(context)!.submitApplication;
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
  await tester.pump();
}

void main() {
  testWidgets(
      'successful application closes focused form without disposing it early',
      (tester) async {
    final repo = _Repo();
    await _open(tester, repo);
    await _submit(tester);
    await tester.pumpAndSettle();
    expect(repo.submissions, 1);
    expect(repo.payload!.proposedBudget, 120.5);
    expect(repo.details, 2);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Repair sink'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dismissing a focused form safely releases its controllers',
      (tester) async {
    final repo = _Repo();
    await _open(tester, repo);
    Navigator.of(tester.element(find.byType(Form))).pop();
    await tester.pumpAndSettle();
    expect(repo.submissions, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending application cannot submit twice and tolerates dismissal',
      (tester) async {
    final repo = _Repo();
    final result = Completer<void>();
    repo.result = () => result.future;
    await _open(tester, repo);
    await _submit(tester);
    expect(repo.submissions, 1);
    final button = tester.widget<FilledButton>(find.descendant(
        of: find.byType(Form), matching: find.byType(FilledButton)));
    expect(button.onPressed, isNull);
    Navigator.of(tester.element(find.byType(Form))).pop();
    await tester.pumpAndSettle();
    result.complete();
    await tester.pumpAndSettle();
    expect(repo.submissions, 1);
    expect(find.text('Repair sink'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('API failure keeps input available for retry', (tester) async {
    final repo = _Repo();
    repo.result = () async =>
        throw const ApiException(statusCode: 500, message: 'err_server');
    await _open(tester, repo);
    await _submit(tester);
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('120,50'), findsOneWidget);
    repo.result = () async {};
    await _submit(tester);
    await tester.pumpAndSettle();
    expect(repo.submissions, 2);
    expect(find.byType(TextFormField), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final fails in [false, true]) {
    testWidgets(
        'late ${fails ? 'failure' : 'success'} during closing is ignored',
        (tester) async {
      final repo = _Repo();
      final result = Completer<void>();
      final observer = _PopObserver();
      repo.result = () => result.future;
      await _open(tester, repo, observer: observer);
      await _submit(tester);
      final sheetContext = tester.element(find.byType(Form));
      Navigator.of(sheetContext).pop();
      expect(sheetContext.mounted, isTrue);
      if (fails) {
        result.completeError(
            const ApiException(statusCode: 500, message: 'err_server'));
      } else {
        result.complete();
      }
      await tester.pumpAndSettle();
      expect(observer.pops, 1);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.text('Repair sink'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
