import 'package:flutter/material.dart';

import '../../../../core/ui/app_theme.dart';

/// Presentation-only data used by the dashboard widgets.
class DashboardStatData {
  const DashboardStatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
}

enum DashboardTaskFilter { pending, accepted, completed }

enum DashboardTaskStatus { fresh, pending }

class DashboardTaskData {
  const DashboardTaskData({
    required this.title,
    required this.location,
    required this.category,
    required this.timeAgo,
    required this.status,
    required this.statusLabel,
    required this.price,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String location;
  final String category;
  final String timeAgo;
  final DashboardTaskStatus status;
  final String statusLabel;
  final String price;
  final IconData icon;
  final Color accent;
}

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.appName,
    required this.greeting,
    required this.subtitle,
    required this.onlineLabel,
    required this.menuLabel,
    required this.notificationsLabel,
    required this.profileLabel,
    required this.onMenuTap,
    required this.onNotificationsTap,
    required this.onProfileTap,
  });

  final String appName;
  final String greeting;
  final String subtitle;
  final String onlineLabel;
  final String menuLabel;
  final String notificationsLabel;
  final String profileLabel;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark ? scheme.primaryContainer : scheme.primary;
    final foreground = isDark ? scheme.onPrimaryContainer : scheme.onPrimary;
    final safeTop = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: background,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20, safeTop + 14, 20, 52),
        child: Align(
          alignment: AlignmentDirectional.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _HeaderIconButton(
                      icon: Icons.menu_rounded,
                      tooltip: menuLabel,
                      foreground: foreground,
                      onTap: onMenuTap,
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.home_work_rounded, size: 36, color: foreground),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        appName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    _NotificationButton(
                      tooltip: notificationsLabel,
                      foreground: foreground,
                      badgeColor: scheme.error,
                      onTap: onNotificationsTap,
                    ),
                    const SizedBox(width: 10),
                    Tooltip(
                      message: profileLabel,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onProfileTap,
                        child: Container(
                          height: 54,
                          width: 54,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: foreground, width: 1.5),
                            color: scheme.surfaceContainerLowest,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/artisan_cutout.png',
                              fit: BoxFit.cover,
                              alignment: const Alignment(0, -0.82),
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.person_rounded,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 520;
                    final greetingBlock = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: foreground.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                    final availability = _AvailabilityBadge(
                      label: onlineLabel,
                      foreground: foreground,
                      background: foreground.withValues(alpha: 0.12),
                      dotColor: scheme.tertiary,
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          greetingBlock,
                          const SizedBox(height: 16),
                          availability,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: greetingBlock),
                        const SizedBox(width: 24),
                        availability,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(foregroundColor: foreground),
      icon: Icon(icon, size: 32),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.tooltip,
    required this.foreground,
    required this.badgeColor,
    required this.onTap,
  });

  final String tooltip;
  final Color foreground;
  final Color badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(foregroundColor: foreground),
      icon: Badge(
        smallSize: 9,
        backgroundColor: badgeColor,
        child: const Icon(Icons.notifications_none_rounded, size: 30),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({
    required this.label,
    required this.foreground,
    required this.background,
    required this.dotColor,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 18, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 11,
                height: 11,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 9),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardStats extends StatelessWidget {
  const DashboardStats({
    super.key,
    required this.items,
    required this.detailsLabel,
    required this.onTap,
  });

  final List<DashboardStatData> items;
  final String detailsLabel;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  if (index > 0) const SizedBox(width: 14),
                  Expanded(
                    child: DashboardStatCard(
                      data: items[index],
                      detailsLabel: detailsLabel,
                      onTap: () => onTap(index),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.only(end: 4),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: 252,
              child: DashboardStatCard(
                data: items[index],
                detailsLabel: detailsLabel,
                onTap: () => onTap(index),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.data,
    required this.detailsLabel,
    required this.onTap,
  });

  final DashboardStatData data;
  final String detailsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: data.accent.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(data.icon, size: 30, color: data.accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          data.value,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Divider(color: scheme.outlineVariant.withValues(alpha: 0.65)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      detailsLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        TextButton.icon(
          onPressed: onActionTap,
          label: Text(actionLabel),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class DashboardFilterBar extends StatelessWidget {
  const DashboardFilterBar({
    super.key,
    required this.selected,
    required this.pendingLabel,
    required this.acceptedLabel,
    required this.completedLabel,
    required this.onSelected,
  });

  final DashboardTaskFilter selected;
  final String pendingLabel;
  final String acceptedLabel;
  final String completedLabel;
  final ValueChanged<DashboardTaskFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tabs = <(DashboardTaskFilter, String, IconData)>[
      (DashboardTaskFilter.pending, pendingLabel, Icons.schedule_rounded),
      (
        DashboardTaskFilter.accepted,
        acceptedLabel,
        Icons.check_circle_outline_rounded
      ),
      (DashboardTaskFilter.completed, completedLabel, Icons.task_alt_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            Expanded(
              child: _FilterTab(
                label: tab.$2,
                icon: tab.$3,
                selected: selected == tab.$1,
                onTap: () => onSelected(tab.$1),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: foreground),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      theme.textTheme.labelLarge?.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardTaskCard extends StatelessWidget {
  const DashboardTaskCard({super.key, required this.data, required this.onTap});

  final DashboardTaskData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<Lem3alamThemeTokens>()!;
    final statusColor = data.status == DashboardTaskStatus.fresh
        ? scheme.tertiary
        : tokens.warning;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 18, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          data.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 8,
                    runSpacing: 7,
                    children: [
                      _InfoChip(
                        label: data.category,
                        foreground: data.accent,
                        background: data.accent.withValues(alpha: 0.09),
                      ),
                      _InfoChip(
                        label: data.timeAgo,
                        icon: Icons.schedule_rounded,
                        foreground: scheme.onSurfaceVariant,
                        background: scheme.surfaceContainerLow,
                      ),
                    ],
                  ),
                ],
              );

              final trailing = Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoChip(
                    label: data.statusLabel,
                    foreground: statusColor,
                    background: statusColor.withValues(alpha: 0.10),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.price,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, color: scheme.primary),
                    ],
                  ),
                ],
              );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 62 : 76,
                    height: compact ? 76 : 104,
                    decoration: BoxDecoration(
                      color: data.accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(data.icon,
                        size: compact ? 32 : 40, color: data.accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: compact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              details,
                              const SizedBox(height: 12),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                runAlignment: WrapAlignment.spaceBetween,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _InfoChip(
                                    label: data.statusLabel,
                                    foreground: statusColor,
                                    background:
                                        statusColor.withValues(alpha: 0.10),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        data.price,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Icon(Icons.chevron_right_rounded,
                                          color: scheme.primary),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: details),
                              const SizedBox(width: 18),
                              trailing,
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: foreground, size: 16),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: scheme.onSurfaceVariant, size: 34),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class DashboardPromoBanner extends StatelessWidget {
  const DashboardPromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 18, 10),
            child: Row(
              children: [
                SizedBox(
                  width: compact ? 112 : 170,
                  height: compact ? 128 : 146,
                  child: Image.asset(
                    'assets/artisan_cutout.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.62),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            copy,
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: onTap,
                              label: Text(actionLabel),
                              iconAlignment: IconAlignment.end,
                              icon: const Icon(Icons.arrow_forward_rounded),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: copy),
                            const SizedBox(width: 20),
                            FilledButton.icon(
                              onPressed: onTap,
                              label: Text(actionLabel),
                              iconAlignment: IconAlignment.end,
                              icon: const Icon(Icons.arrow_forward_rounded),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DashboardBottomNavigation extends StatelessWidget {
  const DashboardBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.homeLabel,
    required this.tasksLabel,
    required this.postTaskLabel,
    required this.messagesLabel,
    required this.earningsLabel,
    required this.onSelected,
  });

  final int selectedIndex;
  final String homeLabel;
  final String tasksLabel;
  final String postTaskLabel;
  final String messagesLabel;
  final String earningsLabel;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = <(String, IconData, IconData)>[
      (homeLabel, Icons.home_outlined, Icons.home_rounded),
      (tasksLabel, Icons.assignment_outlined, Icons.assignment_rounded),
      (postTaskLabel, Icons.add_rounded, Icons.add_rounded),
      (
        messagesLabel,
        Icons.chat_bubble_outline_rounded,
        Icons.chat_bubble_rounded
      ),
      (
        earningsLabel,
        Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet_rounded
      ),
    ];

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 8,
      shadowColor: scheme.shadow.withValues(alpha: 0.14),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: index == 2
                      ? _PrimaryNavItem(
                          label: items[index].$1,
                          onTap: () => onSelected(index),
                        )
                      : _NavItem(
                          label: items[index].$1,
                          icon: selectedIndex == index
                              ? items[index].$3
                              : items[index].$2,
                          selected: selectedIndex == index,
                          onTap: () => onSelected(index),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(3, 8, 3, 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 27),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 3,
                width: selected ? 34 : 0,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryNavItem extends StatelessWidget {
  const _PrimaryNavItem({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.24),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(Icons.add_rounded, color: scheme.onPrimary, size: 30),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
