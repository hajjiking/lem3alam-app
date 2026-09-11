import 'package:flutter/material.dart';

import '../../../../core/ui/app_theme.dart';
import '../../domain/app_notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.timeLabel,
    required this.newLabel,
    required this.onTap,
  });

  final AppNotification notification;
  final String timeLabel;
  final String newLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final unread = !notification.isRead;
    final category = NotificationCategory.fromType(notification.type);

    return Semantics(
      button: true,
      label: unread
          ? '$newLabel. ${notification.title}. ${notification.message}'
          : '${notification.title}. ${notification.message}',
      child: Card(
        margin: EdgeInsets.zero,
        elevation: unread ? 1 : 0,
        color: unread
            ? context.appColors.primary.withValues(alpha: 0.075)
            : scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: unread
                ? context.appColors.primary.withValues(alpha: 0.24)
                : scheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: category.color(context).withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    category.icon,
                    size: 23,
                    color: category.color(context),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title.isEmpty
                                  ? notification.type.replaceAll('_', ' ')
                                  : notification.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight:
                                    unread ? FontWeight.w900 : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (unread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 9,
                              height: 9,
                              margin: const EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.appColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (notification.message.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          notification.message,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                            color: scheme.onSurfaceVariant,
                            fontWeight: unread ? FontWeight.w600 : null,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        timeLabel,
                        textDirection: Directionality.of(context),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: unread
                              ? context.appColors.primary
                              : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: scheme.onSurfaceVariant,
                  textDirection: Directionality.of(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum NotificationCategory {
  application,
  task,
  message,
  payment,
  review,
  dispute,
  system;

  factory NotificationCategory.fromType(String type) {
    final value = type.toLowerCase();
    if (value.contains('application') || value == 'new_request') {
      return application;
    }
    if (value.contains('message') || value.contains('chat')) return message;
    if (value.contains('payment') ||
        value.contains('earning') ||
        value.contains('payout') ||
        value.contains('fee') ||
        value.contains('refund')) {
      return payment;
    }
    if (value.contains('review') || value.contains('rating')) return review;
    if (value.contains('dispute')) return dispute;
    if (value.contains('task') || value == 'new_request') return task;
    return system;
  }

  IconData get icon => switch (this) {
        application => Icons.person_add_alt_1_rounded,
        task => Icons.task_alt_rounded,
        message => Icons.chat_bubble_outline_rounded,
        payment => Icons.account_balance_wallet_outlined,
        review => Icons.star_outline_rounded,
        dispute => Icons.support_agent_rounded,
        system => Icons.notifications_none_rounded,
      };

  Color color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<Lem3alamThemeTokens>()!;
    return switch (this) {
      application || task => context.appColors.primary,
      message => tokens.info,
      payment => tokens.success,
      review => tokens.warning,
      dispute => scheme.error,
      system => scheme.onSurfaceVariant,
    };
  }
}
