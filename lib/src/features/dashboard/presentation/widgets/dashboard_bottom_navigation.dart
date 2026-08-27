import 'package:flutter/material.dart';

class DashboardBottomNavigation extends StatelessWidget {
  const DashboardBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.homeLabel,
    required this.tasksLabel,
    required this.messagesLabel,
    required this.earningsLabel,
    required this.profileLabel,
    required this.onSelected,
    this.postTaskLabel,
  });

  final int selectedIndex;
  final String homeLabel;
  final String tasksLabel;
  final String messagesLabel;
  final String earningsLabel;
  final String profileLabel;
  final ValueChanged<int> onSelected;
  final String? postTaskLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = <(String, IconData, IconData)>[
      (homeLabel, Icons.home_outlined, Icons.home_rounded),
      (tasksLabel, Icons.assignment_outlined, Icons.assignment_rounded),
      if (postTaskLabel != null)
        (postTaskLabel!, Icons.add_rounded, Icons.add_rounded),
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
      if (postTaskLabel == null)
        (profileLabel, Icons.person_outline_rounded, Icons.person_rounded),
    ];

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 8,
      shadowColor: scheme.shadow.withValues(alpha: 0.14),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: postTaskLabel == null
              ? 76
              : 78 + MediaQuery.textScalerOf(context).scale(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: _NavItem(
                    label: items[index].$1,
                    icon: selectedIndex == index
                        ? items[index].$3
                        : items[index].$2,
                    selected: selectedIndex == index,
                    prominent: postTaskLabel != null && index == 2,
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
    this.prominent = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool prominent;

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
              if (prominent)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: scheme.primary, shape: BoxShape.circle),
                  child: Icon(icon, color: scheme.onPrimary, size: 36),
                )
              else
                Icon(icon, color: color, size: 27),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
              if (!prominent) const SizedBox(height: 3),
              if (!prominent)
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
