import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/admin/domain/admin_dashboard_summary.dart';
import 'package:lem3alam_mobile/src/features/admin/presentation/admin_dashboard_controller.dart';
import 'package:lem3alam_mobile/src/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:lem3alam_mobile/src/features/admin/presentation/widgets/admin_bottom_nav.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';

class _AdminAuthController extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: User(
        id: 1,
        name: 'Admin Lem3alam',
        email: 'admin@lem3alam.ma',
        role: 'admin',
        status: 'active',
        city: 'Rabat',
        adminRole: 'super_admin',
      ),
    );
  }
}

Widget _adminApp({required Locale locale, required ThemeMode themeMode}) {
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(_AdminAuthController.new),
      adminDashboardProvider.overrideWith(
        (ref) async => const AdminDashboardSummary(
          usersCount: 1245,
          tasksCount: 2568,
          disputesCount: 4,
          revenue: 120000,
        ),
      ),
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
      home: Scaffold(
        body: AdminDashboardScreen(
          onMenuTap: _noop,
          onNotificationsTap: _noop,
          onProfileTap: _noop,
          onTasksTap: _noop,
        ),
        bottomNavigationBar: const _TestBottomNavigation(),
      ),
    ),
  );
}

void _noop() {}

class _TestBottomNavigation extends StatelessWidget {
  const _TestBottomNavigation();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdminBottomNavigation(
      selectedIndex: 0,
      homeLabel: l10n.home,
      usersLabel: l10n.users,
      tasksLabel: l10n.tasks,
      postTaskLabel: l10n.dashboardPostTask,
      reportsLabel: l10n.reports,
      moreLabel: l10n.more,
      onSelected: (_) {},
    );
  }
}

void main() {
  testWidgets('admin dashboard renders compact data and interactive range', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _adminApp(locale: const Locale('en'), themeMode: ThemeMode.light),
    );
    await tester.pump();

    expect(find.text('Hello, Admin 👋'), findsOneWidget);
    expect(find.text('Total Users'), findsOneWidget);
    expect(find.text('Post Task'), findsOneWidget);

    await tester.tap(find.text('Online'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Offline'), findsOneWidget);

    final dashboardList = find.byKey(
      const PageStorageKey<String>('admin-dashboard-scroll'),
    );
    final scrollable = find
        .descendant(
          of: dashboardList,
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Tasks Overview'),
      520,
      scrollable: scrollable,
    );
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('This Week'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('This Month').last);
    await tester.pumpAndSettle();
    expect(find.text('This Month'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Top Categories'),
      520,
      scrollable: scrollable,
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Recent Tasks'), findsOneWidget);
    expect(find.text('Home Repairs'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin dashboard supports dark Arabic RTL layout',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _adminApp(locale: const Locale('ar'), themeMode: ThemeMode.dark),
    );
    await tester.pump();

    final dashboard = find.byType(AdminDashboardScreen);
    expect(dashboard, findsOneWidget);
    expect(Directionality.of(tester.element(dashboard)), TextDirection.rtl);
    expect(find.text('مرحباً، Admin 👋'), findsOneWidget);
    expect(find.text('إجمالي المستخدمين'), findsOneWidget);
    expect(find.text('انشر مهمة'), findsOneWidget);

    expect(Theme.of(tester.element(dashboard)).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);
  });
}
