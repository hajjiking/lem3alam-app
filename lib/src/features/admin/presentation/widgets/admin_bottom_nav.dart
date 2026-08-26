import 'package:flutter/material.dart';

class AdminBottomNavigation extends StatelessWidget {
  const AdminBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.homeLabel,
    required this.usersLabel,
    required this.tasksLabel,
    required this.postTaskLabel,
    required this.reportsLabel,
    required this.moreLabel,
    required this.onSelected,
  });

  final int selectedIndex;
  final String homeLabel;
  final String usersLabel;
  final String tasksLabel;
  final String postTaskLabel;
  final String reportsLabel;
  final String moreLabel;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = <(String, IconData, IconData)>[
      (homeLabel, Icons.home_outlined, Icons.home_rounded),
      (usersLabel, Icons.people_outline_rounded, Icons.people_rounded),
      (tasksLabel, Icons.assignment_outlined, Icons.assignment_rounded),
      (postTaskLabel, Icons.add_rounded, Icons.add_rounded),
      (reportsLabel, Icons.analytics_outlined, Icons.analytics_rounded),
      (moreLabel, Icons.more_horiz_rounded, Icons.more_horiz_rounded),
    ];

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 12,
      shadowColor: scheme.shadow.withValues(alpha: 0.18),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 82,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: index == 3
                      ? _PostTaskItem(
                          label: items[index].$1,
                          onTap: () => onSelected(index),
                        )
                      : _AdminNavItem(
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

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
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
      button: true,
      selected: selected,
      label: label,
      child: InkResponse(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(2, 9, 2, 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26),
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
                width: selected ? 32 : 0,
                height: 3,
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

class _PostTaskItem extends StatelessWidget {
  const _PostTaskItem({required this.label, required this.onTap});

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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Transform.translate(
              offset: const Offset(0, -8),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child:
                    Icon(Icons.add_rounded, color: scheme.onPrimary, size: 34),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -5),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
