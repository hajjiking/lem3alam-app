import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/earnings/application/earnings_controller.dart';
import 'package:lem3alam_mobile/src/features/earnings/domain/earnings_models.dart';
import 'package:lem3alam_mobile/src/features/earnings/domain/fee_calculator.dart';
import 'package:lem3alam_mobile/src/features/earnings/presentation/period_selector.dart';
import 'package:lem3alam_mobile/src/features/taskers/application/tasker_own_profile_controller.dart';
import 'package:lem3alam_mobile/src/features/taskers/domain/tasker_own_profile.dart';
import 'package:lem3alam_mobile/src/features/taskers/domain/tasker_profile.dart';
import 'package:lem3alam_mobile/src/features/taskers/domain/tasker_review.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/tasker_own_profile_screen.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/tasker_profile_screen.dart';

class TestAuth extends AuthController {
  @override
  AuthState build() => const AuthState(
      status: AuthStatus.authenticated,
      user: User(
          id: 7,
          name: 'Youssef',
          email: 'y@example.com',
          role: 'tasker',
          status: 'active',
          city: 'Casablanca'));
}

TaskerOwnProfileData profileData() => TaskerOwnProfileData(
      profile: TaskerProfile(
          id: 7,
          name: 'Youssef El Amrani',
          professionalTitle: 'Home Maintenance Specialist',
          city: 'Casablanca',
          bio: 'Professional home maintenance and careful repairs.',
          profileImage: null,
          available: true,
          isVerified: true,
          createdAt: DateTime(2023, 1, 12),
          averageRating: 4.8,
          totalReviews: 32,
          skills: [
            for (var i = 1; i <= 7; i++)
              TaskerSkill(id: i, name: 'Skill $i', isVerified: true)
          ]),
      reviews: [
        for (var i = 1; i <= 3; i++)
          TaskerReview(
              id: i,
              rating: 5,
              comment: 'Excellent work $i',
              createdAtIso:
                  DateTime.now().subtract(Duration(days: i)).toIso8601String(),
              reviewerName: 'Client $i')
      ],
    );

Map<String, dynamic> earningsJson() => {
      'tasker_id': 7,
      'currency': 'MAD',
      'period': 'this_month',
      'start_date': '2026-08-01',
      'end_date': '2026-08-29',
      'as_of': '2026-08-29T12:00:00Z',
      'estimate_fee_rate': '0.05',
      'available_balance': null,
      'stats': {
        'completed_tasks': 5,
        'previous_completed_tasks': 3,
        'in_progress_count': 3,
        'total_jobs_all_time': 40,
        'completed_jobs_all_time': 37,
        'average_rating': 4.8,
        'review_count': 32
      },
    };
Map<String, dynamic> transaction(int id, {bool active = false}) => {
      'id': '${active ? 'task' : 'payment'}:$id',
      'task_id': id,
      'task_title': 'API job $id',
      'category_id': 1,
      'category_name': 'Maintenance',
      'bucket': active ? 'estimate' : 'current',
      'date': '2026-08-${20 + id}',
      'status': active ? 'in_progress' : 'completed',
      'gross_amount': active ? '150.00' : '200.00',
      if (!active) ...{'platform_fee': '10.00', 'net_amount': '190.00'},
    };
EarningsView earningsView() => EarningsView(
    EarningsLedger.fromJson(earningsJson(), [
      TransactionRecord.fromJson(transaction(1)),
      TransactionRecord.fromJson(transaction(2)),
      TransactionRecord.fromJson(transaction(3, active: true)),
    ]),
    const FeeCalculator());

class TestEarnings extends EarningsController {
  @override
  Future<EarningsView> build() async => earningsView();
}

final capture = GlobalKey();
Future<void> pumpProfile(WidgetTester tester,
    {String language = 'en', double width = 360, double scale = 1}) async {
  tester.view.physicalSize = Size(width, 1050);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(TestAuth.new),
        taskerOwnProfileProvider(7).overrideWith((ref) async => profileData()),
        earningsControllerProvider.overrideWith(TestEarnings.new),
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
          home: RepaintBoundary(
              key: capture, child: const TaskerProfileScreen(taskerId: 7)))));
  await tester.pumpAndSettle();
}

Future<void> screenshot(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('PROFILE_SCREENSHOTS')) return;
  await tester.runAsync(() async {
    final image = await (capture.currentContext!.findRenderObject()!
            as RenderRepaintBoundary)
        .toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/profile-previews').create(recursive: true);
    await File('build/profile-previews/$name.png')
        .writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (const bool.fromEnvironment('PROFILE_SCREENSHOTS')) {
      await (FontLoader('Cairo')
            ..addFont(rootBundle.load('assets/fonts/Cairo.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    }
  });
  test(
      'profile statistics and badges use API earnings without invented punctuality',
      () {
    final view = earningsView();
    expect(view.ledger.stats.completedJobsAllTime, 37);
    expect(view.ledger.stats.inProgressCount, 3);
    expect(view.summary.net, 38000);
    expect(
        view.transactions.any((r) => r.status == TransactionStatus.inProgress),
        true);
  });
  testWidgets(
      'signed-in tasker sees own dashboard with real sections and shared period',
      (tester) async {
    await pumpProfile(tester, width: 1100);
    expect(find.byType(TaskerOwnProfileScreen), findsOneWidget);
    expect(find.text('Youssef El Amrani'), findsOneWidget);
    expect(find.text('37'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
    expect(find.text('Punctual'), findsNothing);
    expect(find.byType(PeriodSelector), findsOneWidget);
    expect(find.text('API job 3'), findsOneWidget);
    expect(tester.takeException(), null);
  });
  testWidgets('edit and extra skills are wired without fake forms',
      (tester) async {
    await pumpProfile(tester);
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('+2 more'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+2 more'));
    await tester.pumpAndSettle();
    expect(find.text('Skill 7'), findsOneWidget);
  });
  for (final language in ['en', 'fr', 'ar']) {
    for (final width in [360.0, 1100.0]) {
      testWidgets('$language $width profile layout', (tester) async {
        await pumpProfile(tester, language: language, width: width);
        expect(tester.takeException(), null);
        await screenshot(tester, '$language-$width-header');
        await tester.ensureVisible(find.text(language == 'fr'
            ? 'Compétences et expertise'
            : language == 'ar'
                ? 'المهارات والخبرات'
                : 'Skills & Expertise'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), null);
        await screenshot(tester, '$language-$width-skills');
        await tester.ensureVisible(find.byType(PeriodSelector));
        await tester.pumpAndSettle();
        expect(tester.takeException(), null);
        await screenshot(tester, '$language-$width-earnings');
        await tester.ensureVisible(find.text('API job 3'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), null);
        await screenshot(tester, '$language-$width-jobs');
      });
    }
  }
  testWidgets('large Arabic text remains usable', (tester) async {
    await pumpProfile(tester, language: 'ar', scale: 1.6);
    expect(tester.takeException(), null);
    await tester.ensureVisible(find.text('API job 3'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
  });
}
