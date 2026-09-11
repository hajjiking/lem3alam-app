import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/ui/app_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../application/notification_center_controller.dart';
import '../application/notification_router.dart';
import '../domain/app_notification.dart';
import 'widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(notificationCenterProvider);
      if (!state.hasLoaded) {
        unawaited(
            ref.read(notificationCenterProvider.notifier).fetchNotifications());
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 320) {
      return;
    }
    unawaited(
        ref.read(notificationCenterProvider.notifier).loadMoreNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationCenterProvider);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: state.isLoading ? null : _markAllRead,
              child: Text(l10n.notificationsMarkAllRead),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _body(state),
      ),
    );
  }

  Widget _body(NotificationCenterState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const _NotificationSkeleton();
    }
    if (state.error != null && state.notifications.isEmpty) {
      return _NotificationError(
        message: _errorMessage(state.error!),
        onRetry: () =>
            ref.read(notificationCenterProvider.notifier).fetchNotifications(),
      );
    }
    if (state.notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh:
            ref.read(notificationCenterProvider.notifier).refreshNotifications,
        child: const _NotificationEmpty(),
      );
    }

    final entries = _groupedEntries(state.notifications);
    return RefreshIndicator(
      onRefresh:
          ref.read(notificationCenterProvider.notifier).refreshNotifications,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
        itemCount: entries.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == entries.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final entry = entries[index];
          if (entry is _GroupHeader) {
            return Padding(
              padding: EdgeInsetsDirectional.only(
                top: index == 0 ? 4 : 22,
                bottom: 10,
                start: 4,
              ),
              child: Text(
                entry.label(context),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            );
          }
          final notification = entry as AppNotification;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NotificationTile(
              key: ValueKey(notification.id),
              notification: notification,
              timeLabel: _relativeTime(notification.createdAt),
              newLabel: context.l10n.notificationsNew,
              onTap: () => _open(notification),
            ),
          );
        },
      ),
    );
  }

  List<Object> _groupedEntries(List<AppNotification> notifications) {
    final entries = <Object>[];
    _NotificationGroup? previous;
    for (final notification in notifications) {
      final group = _NotificationGroup.forDate(notification.createdAt);
      if (group != previous) {
        entries.add(_GroupHeader(group));
        previous = group;
      }
      entries.add(notification);
    }
    return entries;
  }

  String _relativeTime(DateTime time) {
    if (time.millisecondsSinceEpoch == 0) return '';
    final difference = DateTime.now().difference(time);
    if (difference.isNegative || difference.inMinutes < 1) {
      return context.l10n.notificationsJustNow;
    }
    if (difference.inHours < 1) {
      return context.l10n.notificationsMinutesAgo(difference.inMinutes);
    }
    if (difference.inDays < 1) {
      return context.l10n.notificationsHoursAgo(difference.inHours);
    }
    return context.l10n.notificationsDaysAgo(difference.inDays);
  }

  Future<void> _open(AppNotification notification) async {
    if (!notification.isRead) {
      unawaited(
        ref
            .read(notificationCenterProvider.notifier)
            .markAsRead(notification)
            .catchError((Object _) {
          if (mounted) _showError(context.l10n.notificationsMarkReadError);
        }),
      );
    }

    final user = ref.read(authControllerProvider).user;
    final navigated = user != null &&
        ref.read(notificationRouterProvider).routeNotification(
              notification,
              currentRole: user.role,
              currentUserId: user.id,
            );
    if (!navigated && mounted) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(notification.title.isEmpty
              ? context.l10n.notificationsTitle
              : notification.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (notification.message.isNotEmpty) Text(notification.message),
              const SizedBox(height: 12),
              Text(
                context.l10n.notificationsNoDestination,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.close),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _markAllRead() async {
    try {
      await ref.read(notificationCenterProvider.notifier).markAllAsRead();
    } on Object {
      if (mounted) _showError(context.l10n.notificationsMarkAllError);
    }
  }

  String _errorMessage(Object error) {
    if (error is ApiException) return localizeApiException(context, error);
    return context.l10n.notificationsSomethingWentWrong;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _NotificationGroup {
  today,
  yesterday,
  earlier;

  static _NotificationGroup forDate(DateTime date) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final value = DateTime(date.year, date.month, date.day);
    if (value == todayDate) return _NotificationGroup.today;
    if (value == todayDate.subtract(const Duration(days: 1))) {
      return _NotificationGroup.yesterday;
    }
    return _NotificationGroup.earlier;
  }
}

class _GroupHeader {
  const _GroupHeader(this.group);
  final _NotificationGroup group;

  String label(BuildContext context) => switch (group) {
        _NotificationGroup.today => context.l10n.notificationsToday,
        _NotificationGroup.yesterday => context.l10n.notificationsYesterday,
        _NotificationGroup.earlier => context.l10n.notificationsEarlier,
      };
}

class _NotificationEmpty extends StatelessWidget {
  const _NotificationEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.16),
        Icon(
          Icons.notifications_none_rounded,
          size: 76,
          color: scheme.primary.withValues(alpha: 0.65),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.notificationsEmptyTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        AppResponsiveCenter(
          maxWidth: 430,
          child: Text(
            l10n.notificationsEmptyBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }
}

class _NotificationError extends StatelessWidget {
  const _NotificationError({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppResponsiveCenter(
        maxWidth: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 60, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              context.l10n.notificationsLoadError,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 104,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
