import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:lem3alam_mobile/src/features/dashboard/domain/dashboard_models.dart';
import 'package:lem3alam_mobile/src/features/dashboard/domain/dashboard_repository.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/dashboard_screen.dart';

class _DashboardAuthController extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: User(
        id: 7,
        name: 'Mohamed Amrani',
        email: 'mohamed@example.com',
        role: 'tasker',
        status: 'active',
        city: 'Rabat',
      ),
    );
  }
}

class _EmptyDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSnapshot> fetchDashboard() async => DashboardSnapshot.empty;
}

Widget _dashboardApp({required Locale locale, required ThemeMode themeMode}) {
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(_DashboardAuthController.new),
      dashboardRepositoryProvider
          .overrideWithValue(_EmptyDashboardRepository()),
    ],
    child: MaterialApp(
      locale: locale,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      supportedLocales: const [Locale('ar'), Locale('en'), Locale('fr')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const DashboardScreen(),
    ),
  );
}

void main() {
  testWidgets('dashboard renders an honest empty state without API data', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _dashboardApp(locale: const Locale('en'), themeMode: ThemeMode.light),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hello, Mohamed 👋'), findsOneWidget);
    expect(
      find.text(
        'Analytics for this period are unavailable. Update the server and refresh.',
      ),
      findsOneWidget,
    );
    expect(find.text('Repair washing machine'), findsNothing);

    expect(find.text('Online'), findsNothing);

    expect(find.text('Performance'), findsOneWidget);
    expect(find.text('Active Tasks'), findsOneWidget);
  });

  testWidgets('dashboard supports dark theme and Arabic RTL', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _dashboardApp(locale: const Locale('ar'), themeMode: ThemeMode.dark),
    );
    await tester.pumpAndSettle();

    final dashboard = find.byType(DashboardScreen);
    expect(dashboard, findsOneWidget);
    expect(Directionality.of(tester.element(dashboard)), TextDirection.rtl);
    expect(find.text('مرحباً، Mohamed 👋'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppTheme.dark().colorScheme.surface);

    expect(
      find.text(
        'إحصاءات هذه الفترة غير متاحة. حدّث الخادم ثم أعد التحميل.',
      ),
      findsOneWidget,
    );
  });
}
