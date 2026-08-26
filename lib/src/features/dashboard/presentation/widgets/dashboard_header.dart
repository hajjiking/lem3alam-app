import 'package:flutter/material.dart';

import '../../../../core/ui/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.appName,
    required this.greeting,
    required this.subtitle,
    required this.availabilityLabel,
    required this.isOnline,
    required this.menuLabel,
    required this.notificationsLabel,
    required this.profileLabel,
    required this.onMenuTap,
    required this.onNotificationsTap,
    required this.onProfileTap,
    required this.onAvailabilityTap,
  });

  final String appName;
  final String greeting;
  final String subtitle;
  final String availabilityLabel;
  final bool isOnline;
  final String menuLabel;
  final String notificationsLabel;
  final String profileLabel;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;
  final VoidCallback onAvailabilityTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<Lem3alamThemeTokens>()!;
    final foreground = theme.brightness == Brightness.dark
        ? scheme.onPrimaryContainer
        : scheme.onPrimary;
    final safeTop = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [tokens.headerStart, tokens.headerEnd],
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20, safeTop + 24, 20, 67),
        child: Align(
          alignment: AlignmentDirectional.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: menuLabel,
                      onPressed: onMenuTap,
                      style: IconButton.styleFrom(foregroundColor: foreground),
                      icon: const Icon(Icons.menu_rounded, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.home_work_rounded,
                          size: 32, color: foreground),
                    ),
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
                    IconButton(
                      tooltip: notificationsLabel,
                      onPressed: onNotificationsTap,
                      style: IconButton.styleFrom(foregroundColor: foreground),
                      icon: Badge(
                        smallSize: 9,
                        backgroundColor: scheme.error,
                        child: const Icon(Icons.notifications_none_rounded,
                            size: 30),
                      ),
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
                const SizedBox(height: 70),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 360;
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
                      label: availabilityLabel,
                      isOnline: isOnline,
                      foreground: foreground,
                      background: foreground.withValues(alpha: 0.12),
                      onlineColor: scheme.tertiary,
                      offlineColor: scheme.outline,
                      onTap: onAvailabilityTap,
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

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({
    required this.label,
    required this.isOnline,
    required this.foreground,
    required this.background,
    required this.onlineColor,
    required this.offlineColor,
    required this.onTap,
  });

  final String label;
  final bool isOnline;
  final Color foreground;
  final Color background;
  final Color onlineColor;
  final Color offlineColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isOnline,
      label: label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 18, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: isOnline ? onlineColor : offlineColor,
                    shape: BoxShape.circle,
                  ),
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
      ),
    );
  }
}
