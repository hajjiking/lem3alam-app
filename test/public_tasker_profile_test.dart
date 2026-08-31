import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/taskers/domain/public_profile_model.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/public_tasker_profile_screen.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/tasker_public_profile_controller.dart';

PublicProfileModel profile() => PublicProfileModel.fromJson({
      'id': 7,
      'name': 'Youssef El Amrani',
      'profession': 'Home Maintenance Specialist',
      'rating': 4.8,
      'review_count': 32,
      'is_verified': true,
      'is_online': true,
      'city': 'Casablanca',
      'country': 'Morocco',
      'response_minutes': 30,
      'jobs_completed': 47,
      'jobs_completed_this_month': 6,
      'jobs_in_progress': 5,
      'jobs_in_progress_this_month': 2,
      'success_rate': 98,
      'email_verified': true,
      'phone_verified': true,
      'bio': 'Professional home maintenance specialist.',
      'features': ['Plumbing', 'Electrical Work', 'Painting'],
      'additional_skill_count': 3,
      'expertise_items': ['Fixing leaks and pipes', 'Electrical wiring'],
      'reviews': [
        {
          'reviewer_name': 'Amine B.',
          'rating': 5,
          'comment': 'Excellent work!',
          'date_label': '2 days ago',
        }
      ],
    });

Widget app({Locale locale = const Locale('en')}) => ProviderScope(
      overrides: [
        publicTaskerProfileProvider.overrideWith((ref, id) async => profile()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const PublicTaskerProfileScreen(taskerId: 7),
      ),
    );

void main() {
  testWidgets('renders public sections and persists save toggle locally',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Youssef El Amrani'), findsOneWidget);
    expect(find.text('98%'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact Arabic profile is RTL and layout-safe', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(Scaffold).first)),
        TextDirection.rtl);
    expect(find.text('مجالات الخبرة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
