import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/dashboard_actions.dart';
import '../../dashboard/presentation/widgets/dashboard_header.dart';
import '../application/conversations_controller.dart';
import '../domain/conversation_model.dart';
import 'chat_thread_pane.dart';
import 'conversation_list_pane.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key, this.selected});
  final ChatKey? selected;
  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  Timer? _poll;
  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted &&
          TickerMode.of(context) &&
          (ModalRoute.of(context)?.isCurrent ?? true) &&
          (WidgetsBinding.instance.lifecycleState == null ||
              WidgetsBinding.instance.lifecycleState ==
                  AppLifecycleState.resumed)) {
        ref.read(conversationsControllerProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRouteNames.messages);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final l10n = context.l10n;
    final state = ref.watch(conversationsControllerProvider);
    final controller = ref.read(conversationsControllerProvider.notifier);
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      final items = state.asData?.value.items ?? const <ConversationModel>[];
      final selectedFromList =
          items.where((c) => c.key == widget.selected).firstOrNull;
      final details = widget.selected != null && selectedFromList == null
          ? ref.watch(conversationDetailsProvider(widget.selected!))
          : null;
      final selected = selectedFromList ?? details?.asData?.value;
      final phoneThread = !wide && widget.selected != null;
      final thread = selected == null
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (phoneThread) BackButton(onPressed: _back),
              if (details?.isLoading == true || state.isLoading)
                const CircularProgressIndicator()
              else
                Text(state.hasError || details?.hasError == true
                    ? l10n.messagesLoadError
                    : l10n.messagesSelect),
              if (state.hasError || details?.hasError == true)
                TextButton(
                    onPressed: () {
                      controller.refresh();
                      if (widget.selected != null) {
                        ref.invalidate(
                            conversationDetailsProvider(widget.selected!));
                      }
                    },
                    child: Text(l10n.retry)),
            ]))
          : ChatThreadPane(
              key: ValueKey('${user?.id}:${selected.id}'),
              conversation: selected,
              onBack: phoneThread ? _back : null);
      // Both route variants share exactly the same list and thread widgets.
      // Only the composition changes at the tablet/desktop breakpoint.
      if (phoneThread) return SafeArea(child: thread);
      final search = Row(children: [
        Expanded(
            child: TextFormField(
                key: ValueKey('message-search-${user?.id}'),
                initialValue: state.asData?.value.query ?? '',
                onChanged: controller.search,
                decoration: InputDecoration(
                    hintText: l10n.messagesSearch,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface))),
        const SizedBox(width: 10),
        PopupMenuButton<ConversationFilter>(
            tooltip: l10n.messagesFilters,
            style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface),
            icon: const Icon(Icons.tune),
            onSelected: controller.filter,
            itemBuilder: (_) => [
                  for (final f in ConversationFilter.values)
                    PopupMenuItem(
                        value: f,
                        child: Text(conversationFilterLabel(context, f)))
                ])
      ]);
      final list = ConversationListPane(
          selected: wide ? widget.selected : null,
          onSelect: (c) {
            final params = {'peerId': '${c.contactId}'};
            final query = {if (c.taskId != null) 'task_id': '${c.taskId}'};
            if (wide) {
              context.goNamed(AppRouteNames.messageThread,
                  pathParameters: params, queryParameters: query);
            } else {
              context.pushNamed(AppRouteNames.messageThread,
                  pathParameters: params, queryParameters: query);
            }
          });
      return ColoredBox(
          color: Theme.of(context).extension<Lem3alamThemeTokens>()!.headerEnd,
          child: Column(children: [
            DashboardHeader(
                appName: l10n.appName,
                greeting: l10n.dashboardMessages,
                subtitle: l10n.messagesSubtitle(user?.role ?? 'other'),
                availabilityLabel: '',
                isOnline: false,
                showAvailability: false,
                compact: true,
                titleActions: search,
                avatarAsset: null,
                menuLabel: l10n.dashboardMenu,
                notificationsLabel: l10n.dashboardNotifications,
                profileLabel: l10n.dashboardProfile,
                onMenuTap: () => showDashboardMenu(context, ref),
                onNotificationsTap: () => showDashboardFeatureNotice(
                    context, l10n.dashboardNotifications),
                onProfileTap: () => openDashboardProfile(
                    context, user?.id, user?.isTasker == true),
                onAvailabilityTap: () {}),
            Expanded(
                child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28))),
                    padding: EdgeInsets.all(wide ? 20 : 8),
                    child: wide
                        ? Row(children: [
                            SizedBox(width: 350, child: list),
                            const VerticalDivider(width: 24),
                            Expanded(child: thread)
                          ])
                        : list)),
          ]));
    });
  }
}
