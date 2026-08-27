import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/core/ui/app_widgets.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/login_screen.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/register_screen.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/widgets/availability_calendar.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/widgets/review_card.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/widgets/service_card.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/widgets/statistic_card.dart';
import 'package:lem3alam_mobile/src/features/taskers/domain/public_profile_model.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/tasker_profile_screen.dart';
import 'package:lem3alam_mobile/src/features/taskers/presentation/tasker_public_profile_controller.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/task_form_screen.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/task_style.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/tasks_controller.dart';

Widget _app(Widget child, ThemeData theme,
    {Locale locale = const Locale('en'), double scale = 1}) {
  return ProviderScope(
    overrides: [
      categoryOptionsProvider.overrideWith((ref) async => const []),
      publicTaskerProfileProvider
          .overrideWith((ref, id) async => PublicProfileModel.fromJson({
                'id': id,
                'name': 'Mohamed Amrani',
                'profession': 'Home repairs',
                'rating': 4.8,
                'review_count': 32,
                'is_verified': true,
                'available_today': true,
                'city': 'Rabat',
                'bio': 'Reliable help with everyday repairs.',
                'features': ['Plumbing', 'Electrical'],
                'services': [
                  {'name': 'Plumbing repair', 'starting_price': 150}
                ],
                'reviews': [
                  {
                    'reviewer_name': 'Amina',
                    'rating': 5,
                    'comment': 'Excellent service',
                    'date_label': 'Today'
                  }
                ],
              })),
    ],
    child: MaterialApp(
      theme: theme,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: child,
    ),
  );
}

// Optional local visual QA: flutter test --dart-define=THEME_SNAPSHOTS=true
Future<void> _snapshot(WidgetTester tester, GlobalKey key, String name) async {
  if (!const bool.fromEnvironment('THEME_SNAPSHOTS')) return;
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
  });
  await tester.pump();
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory =
        await Directory('build/theme_preview').create(recursive: true);
    await File('${directory.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    test('$mode controls share palette, shape and type', () {
      final theme = dark ? AppTheme.dark() : AppTheme.light();
      final scheme = theme.colorScheme;
      final filled = theme.filledButtonTheme.style!;
      final elevated = theme.elevatedButtonTheme.style!;
      expect(filled.backgroundColor!.resolve({}), scheme.primary);
      expect(elevated.backgroundColor!.resolve({}), scheme.primary);
      expect(filled.foregroundColor!.resolve({}), scheme.onPrimary);
      expect(elevated.foregroundColor!.resolve({}), scheme.onPrimary);
      expect(filled.shape!.resolve({}), elevated.shape!.resolve({}));
      expect(filled.elevation!.resolve({}), 0);
      expect(theme.textButtonTheme.style!.foregroundColor!.resolve({}),
          scheme.primary);
      expect(theme.outlinedButtonTheme.style!.foregroundColor!.resolve({}),
          scheme.primary);
      expect(theme.textTheme.titleMedium!.fontFamily,
          theme.textTheme.bodyMedium!.fontFamily);
      expect(
          theme.navigationBarTheme.iconTheme!
              .resolve({WidgetState.selected})!.color,
          scheme.primary);
    });

    for (final entry in <String, Widget>{
      'login': const LoginScreen(),
      'register': const RegisterScreen(),
      'task_form': const TaskFormScreen(),
    }.entries) {
      testWidgets('$mode ${entry.key} supports compact RTL and larger text',
          (tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final theme = dark ? AppTheme.dark() : AppTheme.light();
        final key = GlobalKey();
        await tester.pumpWidget(_app(
          RepaintBoundary(key: key, child: entry.value),
          theme,
          locale: const Locale('ar'),
          scale: 1.15,
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(Directionality.of(tester.element(find.byType(Scaffold).first)),
            TextDirection.rtl);
        await _snapshot(tester, key, '${entry.key}_$mode');
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('$mode shared components use themed surfaces', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final theme = dark ? AppTheme.dark() : AppTheme.light();
      final key = GlobalKey();
      await tester.pumpWidget(_app(
        RepaintBoundary(
          key: key,
          child: Scaffold(
            appBar: AppBar(title: const Text('Lem3alam')),
            body: ListView(
              padding: const EdgeInsets.all(AppStyle.pagePadding),
              children: [
                AppSectionCard(
                  title: 'Find your next professional',
                  subtitle: 'Consistent controls and surfaces',
                  child: Column(children: [
                    const TextField(
                        decoration: InputDecoration(
                            labelText: 'Search services',
                            prefixIcon: Icon(Icons.search))),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: FilledButton(
                              onPressed: () {}, child: const Text('Continue'))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: OutlinedButton(
                              onPressed: () {}, child: const Text('Cancel'))),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                StatisticCard(items: const [
                  StatisticItem(
                      icon: Icons.star_rounded, label: 'Rating', value: '4.8'),
                  StatisticItem(
                      icon: Icons.task_alt, label: 'Completed', value: '32'),
                ]),
                const SizedBox(height: 16),
                const ReviewCard(
                    reviewerName: 'Amina',
                    rating: 4.5,
                    comment: 'Excellent work and communication.',
                    dateLabel: 'Today'),
                const SizedBox(height: 16),
                ServiceCard(
                    icon: Icons.plumbing,
                    name: 'Plumbing',
                    startingPrice: 150,
                    onBook: () {}),
              ],
            ),
          ),
        ),
        theme,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final card = tester.widget<Card>(find.byType(Card).first);
      expect(card.shape, isNull,
          reason: 'Section cards inherit the global card theme');
      final context = tester.element(find.byType(StatisticCard));
      expect(AppStyle.cardDecoration(context).color,
          theme.colorScheme.surfaceContainerLowest);
      expect(taskUrgencyColor(context, 'medium'), context.appTokens.warning);
      expect(taskStatusColor(context, 'completed'), context.appTokens.success);
      await _snapshot(tester, key, 'components_$mode');
    });

    testWidgets('$mode calendar remains readable after selection',
        (tester) async {
      final theme = dark ? AppTheme.dark() : AppTheme.light();
      await tester.pumpWidget(_app(
        Scaffold(
            body: SingleChildScrollView(
                child: AvailabilityCalendar(
                    initialMonth: DateTime(DateTime.now().year + 1, 1)))),
        theme,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final date = tester.widget<Text>(find.text('15'));
      expect(date.style!.color, theme.colorScheme.onPrimary);
    });

    testWidgets('$mode profile tabs render without layout errors',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final theme = dark ? AppTheme.dark() : AppTheme.light();
      final key = GlobalKey();
      await tester.pumpWidget(_app(
        RepaintBoundary(
            key: key, child: const TaskerProfileScreen(taskerId: 1)),
        theme,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _snapshot(tester, key, 'profile_$mode');
      for (var index = 1;
          index < tester.widget<TabBar>(find.byType(TabBar)).tabs.length;
          index++) {
        tester.widget<TabBar>(find.byType(TabBar)).controller!.animateTo(index);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Profile tab $index');
      }
    });
  }
}
