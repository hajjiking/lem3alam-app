import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/language_picker.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final canCreateTask = user?.role == 'client';
    final isTasker = user?.role == 'tasker';
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 84,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboard,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              (user?.name ?? '').trim().isEmpty ? l10n.hello : l10n.helloName(user!.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => showLanguagePicker(context),
            icon: const Icon(Icons.language),
            tooltip: l10n.languageAction,
          ),
          const AppThemeModeButton(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.goNamed(AppRouteNames.login);
            },
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: AppResponsiveCenter(
          maxWidth: 920,
          padding: EdgeInsets.zero,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            children: [
              AppHeroPromoCard(
                title: isTasker ? 'Ready to take on new tasks today?' : l10n.promoTodayTitle,
                subtitle: isTasker ? 'Browse nearby, high-priority jobs matched to your skills.' : l10n.promoTodaySubtitle,
                ctaLabel: canCreateTask ? l10n.bookNow : (isTasker ? 'Find jobs' : l10n.tasks),
                icon: isTasker ? Icons.work_history_rounded : Icons.handyman_outlined,
                onCtaTap: () {
                  if (canCreateTask) {
                    context.goNamed(AppRouteNames.taskCreate);
                  } else if (isTasker) {
                    context.goNamed(AppRouteNames.nearbyTasks);
                  } else {
                    context.goNamed(AppRouteNames.tasks);
                  }
                },
              ),
              const SizedBox(height: 22),
              AppSectionHeader(
                title: l10n.shortcuts,
                subtitle: 'Everything you need, one tap away.',
                actionLabel: l10n.more,
                onActionTap: () {},
              ),
              const SizedBox(height: 12),
              _ShortcutGrid(
                canCreateTask: canCreateTask,
                userId: user?.id,
                isTasker: isTasker,
              ),
              const SizedBox(height: 24),
              AppSectionHeader(
                title: 'My activity',
                subtitle: 'Track your most recent bookings and requests.',
                actionLabel: l10n.seeAll,
                onActionTap: () => context.goNamed(AppRouteNames.tasks),
              ),
              const SizedBox(height: 12),
              _ActivityTabs(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({
    required this.canCreateTask,
    required this.userId,
    required this.isTasker,
  });

  final bool canCreateTask;
  final int? userId;
  final bool isTasker;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tiles = <_ShortcutTileData>[
      _ShortcutTileData(
        title: l10n.tasks,
        subtitle: l10n.tasksSubtitle,
        icon: Icons.work_outline,
        accentColor: Lem3alamColors.primaryBlue,
        onTap: () => context.goNamed(AppRouteNames.tasks),
      ),
      _ShortcutTileData(
        title: l10n.categories,
        subtitle: l10n.browseTasksByCategory,
        icon: Icons.category_outlined,
        accentColor: const Color(0xFFF59E0B),
        onTap: () => context.goNamed(AppRouteNames.dashboardCategories),
      ),
      if (canCreateTask)
        _ShortcutTileData(
          title: l10n.createTask,
          subtitle: 'Post a job in 30s',
          icon: Icons.add_task_rounded,
          accentColor: Lem3alamColors.accentGreen,
          onTap: () => context.goNamed(AppRouteNames.taskCreate),
        ),
      if (canCreateTask)
        _ShortcutTileData(
          title: l10n.nearbyArtisans,
          subtitle: l10n.seeTaskersOnMap,
          icon: Icons.map_outlined,
          accentColor: const Color(0xFF8B5CF6),
          onTap: () => context.goNamed(AppRouteNames.nearbyProvidersMap),
        ),
      if (isTasker && userId != null)
        _ShortcutTileData(
          title: l10n.nearbyTasks,
          subtitle: l10n.jobsMatchedToYourLocation,
          icon: Icons.near_me_outlined,
          accentColor: const Color(0xFFEF4444),
          onTap: () => context.goNamed(AppRouteNames.nearbyTasks),
        ),
      if (isTasker && userId != null)
        _ShortcutTileData(
          title: l10n.myProfile,
          subtitle: l10n.publicTaskerProfile,
          icon: Icons.person_outline,
          accentColor: Lem3alamColors.primaryBlue,
          onTap: () => context.goNamed(
            AppRouteNames.taskerProfile,
            pathParameters: {'id': userId.toString()},
          ),
        ),
      if (isTasker && userId != null)
        _ShortcutTileData(
          title: l10n.myReviews,
          subtitle: l10n.ratingsAndFeedback,
          icon: Icons.star_outline,
          accentColor: const Color(0xFFF59E0B),
          onTap: () => context.goNamed(
            AppRouteNames.taskerReviews,
            pathParameters: {'id': userId.toString()},
          ),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 380 ? 2 : (width < 640 ? 3 : 4);
        final itemWidth = (width - ((crossAxisCount - 1) * 12)) / crossAxisCount;

        const minTileHeight = 136.0;
        const maxTileHeight = 160.0;
        final tileHeight = (minTileHeight + itemWidth * 0.12).clamp(minTileHeight, maxTileHeight);
        final aspect = itemWidth / tileHeight;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspect,
          ),
          itemBuilder: (context, index) => _ShortcutTile(data: tiles[index]),
        );
      },
    );
  }
}

class _ShortcutTileData {
  const _ShortcutTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({required this.data});

  final _ShortcutTileData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadow = isDark
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ];

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: data.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
          boxShadow: shadow,
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: data.accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, color: data.accentColor, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              data.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                data.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTabs extends ConsumerStatefulWidget {
  const _ActivityTabs();

  @override
  ConsumerState<_ActivityTabs> createState() => _ActivityTabsState();
}

class _ActivityTabsState extends ConsumerState<_ActivityTabs> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [
      AppSegmentedTab<int>(label: 'Upcoming', value: 0),
      AppSegmentedTab<int>(label: l10n.statusCompleted, value: 1),
      AppSegmentedTab<int>(label: l10n.statusCancelled, value: 2),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSegmentedTabBar<int>(
          tabs: tabs,
          selected: _segment,
          onSelected: (v) => setState(() => _segment = v),
        ),
        const SizedBox(height: 14),
        switch (_segment) {
          0 => _ActivityList(
              children: [
                _ActivityTile(
                  title: 'Plumbing · Kitchen sink',
                  subtitle: 'Tomorrow, 10:00 AM · Casablanca',
                  trailing: '250 MAD',
                  statusLabel: l10n.statusInProgress,
                  statusTone: AppBannerTone.info,
                  icon: Icons.plumbing_outlined,
                  accentColor: Lem3alamColors.primaryBlue,
                  onTap: () => context.goNamed(AppRouteNames.tasks),
                ),
                _ActivityTile(
                  title: 'Electrical repair',
                  subtitle: 'In 2 days, 3:00 PM · Rabat',
                  trailing: '180 MAD',
                  statusLabel: l10n.statusAssigned,
                  statusTone: AppBannerTone.neutral,
                  icon: Icons.bolt_outlined,
                  accentColor: const Color(0xFFF59E0B),
                  onTap: () => context.goNamed(AppRouteNames.tasks),
                ),
              ],
            ),
          1 => _ActivityList(
              children: [
                _ActivityTile(
                  title: 'Home cleaning',
                  subtitle: 'Last week · 3h session',
                  trailing: '320 MAD',
                  statusLabel: l10n.statusCompleted,
                  statusTone: AppBannerTone.success,
                  icon: Icons.cleaning_services_outlined,
                  accentColor: Lem3alamColors.accentGreen,
                  onTap: () => context.goNamed(AppRouteNames.tasks),
                ),
              ],
            ),
          _ => _ActivityList(
              children: [
                _ActivityTile(
                  title: 'Carpentry · Custom shelf',
                  subtitle: 'Cancelled by client · Refund pending',
                  trailing: '—',
                  statusLabel: l10n.statusCancelled,
                  statusTone: AppBannerTone.error,
                  icon: Icons.chair_outlined,
                  accentColor: const Color(0xFFEF4444),
                  onTap: () => context.goNamed(AppRouteNames.tasks),
                ),
              ],
            ),
        },
      ],
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is an early activity preview. Live data will be integrated as the tasks bookings module stabilises.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.statusLabel,
    required this.statusTone,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final String statusLabel;
  final AppBannerTone statusTone;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppStatusChip(label: statusLabel, tone: statusTone),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              trailing,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Lem3alamColors.primaryBlue,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
