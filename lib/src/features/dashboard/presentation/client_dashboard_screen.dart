import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../tasks/data/client_offers_repository.dart';
import '../../tasks/presentation/client_offers_panel.dart';
import '../application/client_dashboard_controller.dart';
import '../domain/client_dashboard_stats.dart';
import '../domain/dashboard_models.dart';
import 'dashboard_actions.dart';
import 'dashboard_screen.dart';
import 'widgets/client_promo_banner.dart';
import 'widgets/client_stats_row.dart';
import 'widgets/dashboard_widgets.dart';

class RoleDashboardScreen extends ConsumerWidget {
  const RoleDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(
              authControllerProvider.select((state) => state.user?.isClient)) ==
          true
      ? const ClientDashboardScreen()
      : const DashboardScreen();
}

class ClientDashboardScreen extends ConsumerWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).user;
    final dashboard = ref.watch(clientDashboardProvider);
    final filter = ref.watch(clientDashboardFilterProvider);
    final name = user?.name.trim() ?? '';
    final taskSectionKey = GlobalKey();

    Future<void> refresh() async {
      // Errors are rendered below; pull-to-refresh must still complete normally.
      ref.invalidate(clientDashboardProvider);
      ref.invalidate(clientOffersProvider);
      try {
        await ref.read(clientDashboardProvider.future);
      } catch (_) {}
    }

    void selectFilter(DashboardTaskFilter value) {
      ref.read(clientDashboardFilterProvider.notifier).select(value);
      final section = taskSectionKey.currentContext;
      if (section != null) {
        Scrollable.ensureVisible(section,
            duration: const Duration(milliseconds: 250));
      }
    }

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            DashboardHeader(
              appName: l10n.appName,
              greeting: l10n.dashboardGreeting(name.isEmpty
                  ? l10n.client
                  : name.split(RegExp(r'\s+')).first),
              subtitle: l10n.clientDashboardReadySubtitle,
              availabilityLabel: l10n.dashboardOffline,
              isOnline: false,
              showAvailability: false,
              avatarAsset: null,
              menuLabel: l10n.dashboardMenu,
              notificationsLabel: l10n.dashboardNotifications,
              profileLabel: l10n.dashboardProfile,
              onMenuTap: () => showDashboardMenu(context, ref),
              onNotificationsTap: () => showDashboardFeatureNotice(
                  context, l10n.dashboardNotifications),
              onProfileTap: () =>
                  openDashboardProfile(context, user?.id, false),
              onAvailabilityTap: () {},
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          dashboard.when(
                            skipLoadingOnRefresh: false,
                            skipLoadingOnReload: false,
                            loading: () => const Padding(
                              padding: EdgeInsets.all(48),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (error, stack) => Column(children: [
                              DashboardEmptyState(
                                  label: l10n.clientDashboardLoadError),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                  onPressed: refresh,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: Text(l10n.retry)),
                            ]),
                            data: (snapshot) => Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClientStatsRow(
                                  stats: ClientDashboardStats.fromDashboard(
                                      snapshot.stats),
                                  onActiveTap: () =>
                                      context.goNamed(AppRouteNames.tasks),
                                  onCompletedTap: () => selectFilter(
                                      DashboardTaskFilter.completed),
                                  onSuccessTap: () => showDialog<void>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title:
                                                Text(l10n.dashboardSuccessRate),
                                            content: Text(l10n
                                                .clientDashboardSuccessInfo),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text(l10n.close),
                                              )
                                            ],
                                          )),
                                ),
                                const SizedBox(height: 28),
                                DashboardSectionHeader(
                                  key: taskSectionKey,
                                  title: l10n.dashboardRecentTasks,
                                  actionLabel: l10n.dashboardViewAll,
                                  onActionTap: () =>
                                      context.goNamed(AppRouteNames.tasks),
                                ),
                                const SizedBox(height: 10),
                                DashboardFilterBar(
                                  selected: filter,
                                  pendingLabel: l10n.dashboardPendingCount(
                                      snapshot.stats.pendingTasks),
                                  acceptedLabel: l10n.dashboardAcceptedCount(
                                      snapshot.stats.acceptedTasks),
                                  completedLabel: l10n.dashboardCompletedFilter,
                                  onSelected: ref
                                      .read(clientDashboardFilterProvider
                                          .notifier)
                                      .select,
                                ),
                                const SizedBox(height: 14),
                                _ClientTasks(
                                    snapshot: snapshot, filter: filter),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const ClientOffersPanel(),
                          const SizedBox(height: 24),
                          ClientPromoBanner(
                              onPostTask: () =>
                                  context.goNamed(AppRouteNames.taskCreate)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientTasks extends StatelessWidget {
  const _ClientTasks({required this.snapshot, required this.filter});

  final DashboardSnapshot snapshot;
  final DashboardTaskFilter filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tasks = clientDashboardTasks(snapshot, filter);
    final numbers = NumberFormat.decimalPattern(l10n.localeName);
    if (tasks.isEmpty) {
      return DashboardEmptyState(
          label: snapshot.stats.activeTasks == 0 &&
                  snapshot.stats.completedTasks == 0 &&
                  snapshot.tasks.isEmpty
              ? l10n.clientDashboardEmpty
              : l10n.clientDashboardNoRecentTasks);
    }
    return Column(children: [
      for (final task in tasks) ...[
        DashboardTaskCard(
          key: ValueKey('client-task-${task.id}'),
          data: DashboardTaskViewData(
            title: task.title,
            location: task.city,
            category: task.category,
            timeAgo: !task.hasCreatedAt
                ? l10n.clientDashboardUnknownTime
                : task.hoursAgo >= 24
                    ? l10n.dashboardDaysAgo(task.hoursAgo ~/ 24)
                    : l10n.dashboardHoursAgo(task.hoursAgo),
            status: task.status,
            statusLabel: switch (task.status) {
              DashboardTaskStatus.fresh => l10n.dashboardStatusNew,
              DashboardTaskStatus.pending => l10n.dashboardStatusPending,
              DashboardTaskStatus.accepted => l10n.statusAssigned,
              DashboardTaskStatus.completed => l10n.statusCompleted,
            },
            price: l10n.dashboardPrice(numbers.format(task.price)),
            icon: switch (task.status) {
              DashboardTaskStatus.accepted => Icons.handyman_outlined,
              DashboardTaskStatus.completed => Icons.task_alt_rounded,
              _ => Icons.home_repair_service_outlined,
            },
            accent: switch (task.status) {
              DashboardTaskStatus.completed => context.appTokens.success,
              DashboardTaskStatus.accepted => context.appTokens.warning,
              _ => context.appColors.primary,
            },
          ),
          onTap: () => context.goNamed(AppRouteNames.taskDetail,
              pathParameters: {'id': task.id.toString()}),
        ),
        const SizedBox(height: 12),
      ],
    ]);
  }
}
