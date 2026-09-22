import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/features/disputes/data/disputes_repository.dart';
import 'package:lem3alam_mobile/src/features/disputes/domain/dispute_draft.dart';
import 'package:lem3alam_mobile/src/features/disputes/presentation/dispute_actions.dart';

class ActionRepository implements DisputesRepository {
  (int, String, String, int)? sent;
  @override
  Future<void> act(int id, String action, String message, int version) async {
    sent = (id, action, message, version);
  }

  @override
  Future<void> submit(DisputeDraft draft) async {}
  @override
  Future<DisputesPage> list({int page = 1}) async =>
      const DisputesPage(items: [], page: 1, lastPage: 1);
}

void main() {
  testWidgets('complainant confirms acceptance with the displayed version',
      (tester) async {
    final repo = ActionRepository();
    var refreshed = false;
    final record = DisputeRecord.fromJson({
      'id': 9,
      'task_id': 3,
      'subject': 'Issue',
      'description': 'Details',
      'status': 'open',
      'workflow_state': 'awaiting_acceptance',
      'workflow_version': 3,
      'allowed_actions': ['accept', 'request_change']
    });
    await tester.pumpWidget(ProviderScope(
        overrides: [disputesRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
                body: DisputeActions(
                    dispute: record, onUpdated: () => refreshed = true)))));
    expect(find.text('Propose a solution'), findsNothing);
    await tester.tap(find.text('Accept solution'));
    await tester.pumpAndSettle();
    expect(repo.sent, isNull);
    await tester.tap(find.widgetWithText(FilledButton, 'Accept solution'));
    await tester.pumpAndSettle();
    expect(repo.sent, (9, 'accept', '', 3));
    expect(refreshed, isTrue);
  });
  testWidgets('appeal requires an explanation before sending', (tester) async {
    final repo = ActionRepository();
    final record = DisputeRecord.fromJson({
      'id': 9,
      'task_id': 3,
      'subject': 'Issue',
      'description': 'Details',
      'status': 'open',
      'allowed_actions': ['propose', 'appeal']
    });
    await tester.pumpWidget(ProviderScope(
        overrides: [disputesRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
                body: DisputeActions(dispute: record, onUpdated: () {})))));
    await tester.tap(find.text('Appeal the complaint'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Send response'))
            .onPressed,
        isNull);
    await tester.enterText(
        find.byType(TextField), 'I disagree because the payment was correct.');
    await tester.pump();
    await tester.tap(find.text('Send response'));
    await tester.pumpAndSettle();
    expect(repo.sent?.$2, 'appeal');
    expect(repo.sent?.$3, 'I disagree because the payment was correct.');
  });
}
