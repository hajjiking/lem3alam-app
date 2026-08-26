import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/language_picker.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/admin_report_item.dart';
import '../domain/admin_nearby_task_settings.dart';
import '../domain/admin_user_item.dart';
import 'admin_dashboard_screen.dart';
import 'admin_dashboard_controller.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  int _selectedIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(adminActionControllerProvider);
    final isBusy = actionState.isLoading;
    final l10n = context.l10n;

    final body = switch (_selectedIndex) {
      1 => _AdminSectionPage(
          title: l10n.users,
          child: _UsersTab(
            searchController: _searchController,
            query: _query,
            onQueryChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
            isBusy: isBusy,
          ),
        ),
      4 => _AdminSectionPage(
          title: l10n.reports,
          child: _ReportsTab(isBusy: isBusy),
        ),
      5 => _AdminSectionPage(
          title: l10n.settings,
          child: _SettingsTab(isBusy: isBusy),
        ),
      _ => AdminDashboardScreen(
          onMenuTap: () => _showAdminMenu(context),
          onNotificationsTap: () =>
              _showFeatureNotice(l10n.dashboardNotifications),
          onProfileTap: () => _showFeatureNotice(l10n.dashboardProfile),
          onTasksTap: () => context.goNamed(AppRouteNames.tasks),
        ),
    };

    return Scaffold(
      body: Column(
        children: [
          if (actionState.hasError)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
                child: AppInlineBanner(
                  message: actionState.error.toString(),
                  tone: AppBannerTone.error,
                ),
              ),
            ),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: AdminBottomNavigation(
        selectedIndex: _selectedIndex,
        homeLabel: l10n.home,
        usersLabel: l10n.users,
        tasksLabel: l10n.tasks,
        postTaskLabel: l10n.dashboardPostTask,
        reportsLabel: l10n.reports,
        moreLabel: l10n.more,
        onSelected: _selectNavigation,
      ),
    );
  }

  void _selectNavigation(int index) {
    if (index == 2) {
      context.goNamed(AppRouteNames.tasks);
      return;
    }
    if (index == 3) {
      _showFeatureNotice(context.l10n.dashboardPostTask);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _showFeatureNotice(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.dashboardFeatureUnavailable(feature)),
        ),
      );
  }

  Future<void> _showAdminMenu(BuildContext context) async {
    final l10n = context.l10n;
    final isDark =
        ref.read(themeModeControllerProvider.notifier).effectiveBrightness ==
            Brightness.dark;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: Text(l10n.refreshAction),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref.read(adminActionControllerProvider.notifier).refreshAll();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(l10n.languageAction),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showLanguagePicker(context);
              },
            ),
            ListTile(
              leading: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              title: Text(
                isDark ? l10n.dashboardLightMode : l10n.dashboardDarkMode,
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref.read(themeModeControllerProvider.notifier).toggle();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: Text(l10n.logout),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.goNamed(AppRouteNames.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSectionPage extends StatelessWidget {
  const _AdminSectionPage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _UsersTab extends ConsumerWidget {
  const _UsersTab({
    required this.searchController,
    required this.query,
    required this.onQueryChanged,
    required this.isBusy,
  });

  final TextEditingController searchController;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final bool isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    final l10n = context.l10n;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(adminActionControllerProvider.notifier).refreshAll(),
      child: usersAsync.when(
        data: (page) {
          final filtered = page.items.where((user) {
            if (query.isEmpty) return true;
            final haystack =
                '${user.name} ${user.email} ${user.role} ${user.city ?? ''}'
                    .toLowerCase();
            return haystack.contains(query);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: searchController,
                onChanged: onQueryChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.searchUsers,
                ),
              ),
              const SizedBox(height: 12),
              AppSectionCard(
                title: l10n.userModeration,
                subtitle:
                    l10n.loadedUsersFromAdminApi(page.items.length, page.total),
                trailing: isBusy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
                child: filtered.isEmpty
                    ? AppEmptyState(
                        title: l10n.noUsersFound,
                        subtitle: l10n.tryDifferentSearchOrRefresh,
                        icon: Icons.people_outline,
                      )
                    : Column(
                        children: [
                          for (final user in filtered) ...[
                            _AdminUserTile(user: user),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
        error: (error, _) => AppErrorState(
          title: l10n.unableToLoadUsers,
          subtitle: l10n.adminUsersEndpointFailed,
          debugDetails: error.toString(),
          onRetry: () =>
              ref.read(adminActionControllerProvider.notifier).refreshAll(),
        ),
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            AppSkeletonBox(height: 54),
            SizedBox(height: 12),
            AppSkeletonBox(height: 120),
            SizedBox(height: 10),
            AppSkeletonBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab({required this.isBusy});

  final bool isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(adminReportsProvider);
    final l10n = context.l10n;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(adminActionControllerProvider.notifier).refreshAll(),
      child: reportsAsync.when(
        data: (page) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppSectionCard(
                title: l10n.reportsComplaints,
                subtitle: l10n.loadedReportsFromSharedBackend(
                    page.items.length, page.total),
                trailing: isBusy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
                child: page.items.isEmpty
                    ? AppEmptyState(
                        title: l10n.noReportsFound,
                        subtitle: l10n.noUserReportsToModerate,
                        icon: Icons.flag_outlined,
                      )
                    : Column(
                        children: [
                          for (final report in page.items) ...[
                            _AdminReportTile(report: report),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
        error: (error, _) => AppErrorState(
          title: l10n.unableToLoadReports,
          subtitle: l10n.adminReportsEndpointFailed,
          debugDetails: error.toString(),
          onRetry: () =>
              ref.read(adminActionControllerProvider.notifier).refreshAll(),
        ),
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            AppSkeletonBox(height: 120),
            SizedBox(height: 10),
            AppSkeletonBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends ConsumerStatefulWidget {
  const _SettingsTab({required this.isBusy});

  final bool isBusy;

  @override
  ConsumerState<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<_SettingsTab> {
  late final TextEditingController _defaultRadiusController;
  late final TextEditingController _minRadiusController;
  late final TextEditingController _maxRadiusController;
  late final TextEditingController _refreshController;
  String _urgency = 'high';
  bool _notificationsEnabled = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _defaultRadiusController = TextEditingController();
    _minRadiusController = TextEditingController();
    _maxRadiusController = TextEditingController();
    _refreshController = TextEditingController();
  }

  @override
  void dispose() {
    _defaultRadiusController.dispose();
    _minRadiusController.dispose();
    _maxRadiusController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _hydrate(AdminNearbyTaskSettings settings) {
    if (_initialized) return;
    _defaultRadiusController.text = settings.defaultRadiusKm.toString();
    _minRadiusController.text = settings.minRadiusKm.toString();
    _maxRadiusController.text = settings.maxRadiusKm.toString();
    _refreshController.text = settings.refreshIntervalMinutes.toString();
    _urgency = settings.notificationMinUrgency;
    _notificationsEnabled = settings.notificationsEnabled;
    _initialized = true;
  }

  Future<void> _save() async {
    final payload = AdminNearbyTaskSettings(
      defaultRadiusKm: int.tryParse(_defaultRadiusController.text) ?? 50,
      minRadiusKm: int.tryParse(_minRadiusController.text) ?? 5,
      maxRadiusKm: int.tryParse(_maxRadiusController.text) ?? 100,
      refreshIntervalMinutes: int.tryParse(_refreshController.text) ?? 15,
      notificationMinUrgency: _urgency,
      notificationsEnabled: _notificationsEnabled,
    );
    await ref
        .read(adminActionControllerProvider.notifier)
        .updateNearbyTaskSettings(payload);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.nearbyTaskSettingsUpdated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(adminNearbyTaskSettingsProvider);
    final l10n = context.l10n;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(adminActionControllerProvider.notifier).refreshAll(),
      child: settingsAsync.when(
        data: (settings) {
          _hydrate(settings);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppSectionCard(
                title: l10n.nearbyTaskControls,
                subtitle: l10n.nearbyTaskControlsSubtitle,
                trailing: widget.isBusy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
                child: Column(
                  children: [
                    TextField(
                      controller: _defaultRadiusController,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: l10n.defaultRadiusKm),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _minRadiusController,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: l10n.minimumRadiusKm),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _maxRadiusController,
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: l10n.maximumRadiusKm),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _refreshController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: l10n.refreshIntervalMinutes),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _urgency,
                      decoration:
                          InputDecoration(labelText: l10n.notifyFromUrgency),
                      items: [
                        DropdownMenuItem(
                            value: 'low', child: Text(l10n.urgencyLow)),
                        DropdownMenuItem(
                            value: 'medium', child: Text(l10n.urgencyMedium)),
                        DropdownMenuItem(
                            value: 'high', child: Text(l10n.urgencyHigh)),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _urgency = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _notificationsEnabled,
                      onChanged: (value) =>
                          setState(() => _notificationsEnabled = value),
                      title: Text(l10n.enableHighPriorityAlerts),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: widget.isBusy ? null : _save,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(l10n.saveSettings),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        error: (error, _) => AppErrorState(
          title: l10n.unableToLoadSettings,
          subtitle: l10n.nearbyTaskSettingsEndpointFailed,
          debugDetails: error.toString(),
          onRetry: () =>
              ref.read(adminActionControllerProvider.notifier).refreshAll(),
        ),
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            AppSkeletonBox(height: 280),
          ],
        ),
      ),
    );
  }
}

class _AdminUserTile extends ConsumerWidget {
  const _AdminUserTile({required this.user});

  final AdminUserItem user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: scheme.surfaceContainerLowest,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        title: Text(user.name,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.email),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppPill(
                    label: user.role,
                    background: scheme.secondaryContainer,
                    foreground: scheme.onSecondaryContainer,
                  ),
                  if (user.isVerified)
                    AppPill(
                      label: l10n.verified,
                      background: scheme.primaryContainer,
                      foreground: scheme.onPrimaryContainer,
                    ),
                  AppPill(
                    label: user.status,
                    background: user.isSuspended
                        ? scheme.tertiaryContainer
                        : scheme.surfaceContainerHigh,
                    foreground: user.isSuspended
                        ? scheme.onTertiaryContainer
                        : scheme.onSurface,
                  ),
                  if ((user.city ?? '').isNotEmpty)
                    AppPill(
                      label: user.city!,
                      background: scheme.surfaceContainerHigh,
                      foreground: scheme.onSurface,
                    ),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            final controller = ref.read(adminActionControllerProvider.notifier);
            switch (value) {
              case 'verify':
                await controller.verifyUser(user.id);
                break;
              case 'ban':
                await controller.toggleBan(user);
                break;
              case 'suspend':
                await controller.toggleSuspension(user);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'verify', child: Text(l10n.verifyAction)),
            PopupMenuItem(
                value: 'ban',
                child: Text(user.isBanned ? l10n.unban : l10n.ban)),
            PopupMenuItem(
                value: 'suspend',
                child: Text(
                    user.isSuspended ? l10n.unsuspend : l10n.suspend7Days)),
          ],
        ),
      ),
    );
  }
}

class _AdminReportTile extends ConsumerWidget {
  const _AdminReportTile({required this.report});

  final AdminReportItem report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: scheme.surfaceContainerLowest,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        title: Text(report.reason,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(report.description ?? l10n.noDescriptionProvided),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppPill(
                    label: report.status,
                    background: scheme.secondaryContainer,
                    foreground: scheme.onSecondaryContainer,
                  ),
                  if ((report.createdAtLabel ?? '').isNotEmpty)
                    AppPill(
                      label: report.createdAtLabel!,
                      background: scheme.surfaceContainerHigh,
                      foreground: scheme.onSurface,
                    ),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            final controller = ref.read(adminActionControllerProvider.notifier);
            switch (value) {
              case 'resolve':
                await controller.resolveReport(report.id);
                break;
              case 'dismiss':
                await controller.dismissReport(report.id);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'resolve', child: Text(l10n.resolve)),
            PopupMenuItem(value: 'dismiss', child: Text(l10n.dismiss)),
          ],
        ),
      ),
    );
  }
}
