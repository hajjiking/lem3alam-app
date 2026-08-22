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
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 84,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
        titleSpacing: 20,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      colorScheme.primaryContainer.withValues(alpha: 0.08),
                      Colors.transparent,
                    ]
                  : [
                      colorScheme.primaryContainer.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              l10n.dashboard,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
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
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: isDark 
                  ? colorScheme.primaryContainer.withValues(alpha: 0.15)
                  : colorScheme.primaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => showLanguagePicker(context),
              icon: const Icon(Icons.language_outlined),
              tooltip: l10n.languageAction,
              style: IconButton.styleFrom(
                minimumSize: const Size(44, 44),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: isDark 
                  ? colorScheme.secondaryContainer.withValues(alpha: 0.15)
                  : colorScheme.secondaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const AppThemeModeButton(),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: isDark 
                  ? colorScheme.tertiaryContainer.withValues(alpha: 0.15)
                  : colorScheme.tertiaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: Badge(
                smallSize: 10,
                largeSize: 20,
                offset: const Offset(6, -6),
                child: const Icon(Icons.notifications_none_rounded),
              ),
              tooltip: l10n.notifications,
              style: IconButton.styleFrom(
                minimumSize: const Size(44, 44),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: isDark 
                  ? colorScheme.errorContainer.withValues(alpha: 0.15)
                  : colorScheme.errorContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.goNamed(AppRouteNames.login);
              },
              icon: const Icon(Icons.logout_rounded),
              tooltip: l10n.logout,
              style: IconButton.styleFrom(
                minimumSize: const Size(44, 44),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
                    colorScheme.surface,
                    colorScheme.surface,
                  ]
                : [
                    colorScheme.primaryContainer.withValues(alpha: 0.25),
                    colorScheme.surface,
                    colorScheme.surface,
                  ],
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: AppResponsiveCenter(
            maxWidth: 920,
            padding: EdgeInsets.zero,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 24),
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
                subtitle: 'Quick actions tailored for you.',
                actionLabel: l10n.more,
                onActionTap: () {},
              ),
              const SizedBox(height: 14),
              _ShortcutGrid(
                canCreateTask: canCreateTask,
                userId: user?.id,
                isTasker: isTasker,
              ),
              const SizedBox(height: 24),
              AppSectionHeader(
                title: 'My activity',
                subtitle: 'Track your recent bookings and task history.',
                actionLabel: l10n.seeAll,
                onActionTap: () => context.goNamed(AppRouteNames.tasks),
              ),
              const SizedBox(height: 14),
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
              color: colorScheme.shadow.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ];

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: data.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withValues(alpha: 0.95),
              ],
            ),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: shadow,
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      data.accentColor.withValues(alpha: 0.15),
                      data.accentColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(data.icon, color: data.accentColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 3),
              Expanded(
                child: Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                ),
              ),
            ],
          ),
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
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withValues(alpha: 0.98),
              ],
            ),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withValues(alpha: 0.18),
                      accentColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 14),
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        AppStatusChip(label: statusLabel, tone: statusTone),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                trailing,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Lem3alamColors.primaryBlue,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
