import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/disputes/domain/dispute_draft.dart';
import 'package:lem3alam_mobile/src/features/disputes/presentation/dispute_details_step.dart';
import 'package:lem3alam_mobile/src/features/disputes/presentation/dispute_evidence_step.dart';
import 'package:lem3alam_mobile/src/features/disputes/presentation/dispute_review_step.dart';
import 'package:lem3alam_mobile/src/features/disputes/presentation/dispute_submitted_step.dart';
import 'package:lem3alam_mobile/src/features/disputes/presentation/dispute_step_indicator.dart';

void main() {
  const draft = DisputeDraft(
      taskId: 1,
      againstUserId: 2,
      againstName: 'Khalid Ait',
      againstRole: 'tasker',
      disputeType: DisputeType.paymentIssue,
      subject: 'Overcharged',
      description: 'Charged more than agreed.');
  for (final language in ['en', 'fr', 'ar']) {
    for (final dark in [false, true]) {
      testWidgets(
          '$language ${dark ? "dark" : "light"}: all steps fit a narrow phone',
          (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final steps = <Widget>[
          DisputeDetailsStep(
              draft: draft, onChanged: (_) {}, taskCard: const SizedBox()),
          DisputeEvidenceStep(
              draft: draft, onChanged: (_) {}, onPick: () {}, onRemove: (_) {}),
          DisputeReviewStep(
              draft: draft, taskCard: const SizedBox(), onEdit: (_) {}),
          const DisputeSubmittedStep(),
        ];
        for (var i = 0; i < steps.length; i++) {
          await tester.pumpWidget(MaterialApp(
              locale: Locale(language),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              home: Scaffold(
                  body: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            if (i < 3) DisputeStepIndicator(step: i),
                            steps[i]
                          ]))))));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}
