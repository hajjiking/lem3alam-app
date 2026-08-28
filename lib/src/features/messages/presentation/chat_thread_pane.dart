import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n.dart';
import '../../../routing/app_router.dart';
import '../../dashboard/presentation/dashboard_actions.dart';
import '../application/chat_thread_controller.dart';
import '../application/conversations_controller.dart';
import '../domain/conversation_model.dart';
import 'chat_input_bar.dart';
import 'chat_message_bubble.dart';
import 'conversation_list_tile.dart';
import 'message_format.dart';
import 'task_context_card.dart';

class ChatThreadPane extends ConsumerStatefulWidget {
  const ChatThreadPane({super.key, required this.conversation, this.onBack});
  final ConversationModel conversation;
  final VoidCallback? onBack;
  @override
  ConsumerState<ChatThreadPane> createState() => _ChatThreadPaneState();
}

class _ChatThreadPaneState extends ConsumerState<ChatThreadPane> {
  final _scroll = ScrollController();
  Timer? _poll;
  bool get _active =>
      mounted &&
      TickerMode.of(context) &&
      (WidgetsBinding.instance.lifecycleState == null ||
          WidgetsBinding.instance.lifecycleState ==
              AppLifecycleState.resumed) &&
      (ModalRoute.of(context)?.isCurrent ?? true);
  @override
  void initState() {
    super.initState();
    _scroll.addListener(_acknowledge);
    _poll = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_active) {
        ref
            .read(
                chatThreadControllerProvider(widget.conversation.key).notifier)
            .refresh();
        _acknowledge();
      }
    });
  }

  void _acknowledge() {
    if (_active && _scroll.hasClients && _scroll.offset < 48) {
      ref
          .read(chatThreadControllerProvider(widget.conversation.key).notifier)
          .acknowledge();
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _menu(String action) async {
    final l10n = context.l10n;
    if (action == 'profile') {
      context.pushNamed(AppRouteNames.taskerProfile,
          pathParameters: {'id': '${widget.conversation.contactId}'});
    } else if (action == 'archive') {
      try {
        await ref
            .read(conversationsControllerProvider.notifier)
            .archive(widget.conversation.id);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.messagesLocalArchive)));
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.errUnknown)));
        }
      }
    } else {
      showDashboardFeatureNotice(context,
          action == 'block' ? l10n.messagesBlock : l10n.messagesReport);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final provider = chatThreadControllerProvider(c.key);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final archived = ref
            .watch(conversationsControllerProvider)
            .asData
            ?.value
            .archived
            .contains(c.id) ??
        false;
    ref.listen(provider, (_, next) {
      if (next.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _acknowledge();
        });
      }
    });
    return ColoredBox(
        color: scheme.surface,
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(children: [
                if (widget.onBack != null) BackButton(onPressed: widget.onBack),
                ContactAvatar(
                    url: c.contactAvatarUrl, online: c.isOnline, size: 40),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(c.contactName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                          c.isOnline == null
                              ? l10n.messagesPresenceUnknown
                              : c.isOnline!
                                  ? l10n.online
                                  : l10n.messagesOffline,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: c.isOnline == true
                                      ? scheme.tertiary
                                      : scheme.onSurfaceVariant)),
                    ])),
                IconButton(
                    tooltip: l10n.messagesCall,
                    onPressed: () =>
                        showDashboardFeatureNotice(context, l10n.messagesCall),
                    icon: const Icon(Icons.call_outlined)),
                PopupMenuButton<String>(
                    tooltip: l10n.messagesMore,
                    onSelected: _menu,
                    itemBuilder: (_) => [
                          if (c.contactRole == 'tasker')
                            PopupMenuItem(
                                value: 'profile',
                                child: Text(l10n.viewProfile)),
                          PopupMenuItem(
                              value: 'archive',
                              child: Text(archived
                                  ? l10n.messagesUnarchive
                                  : l10n.messagesArchive)),
                          PopupMenuItem(
                              value: 'block', child: Text(l10n.messagesBlock)),
                          PopupMenuItem(
                              value: 'report',
                              child: Text(l10n.messagesReport)),
                        ]),
              ])),
          const Divider(height: 1),
          if (c.relatedTask != null &&
              MediaQuery.viewInsetsOf(context).bottom == 0)
            TaskContextCard(task: c.relatedTask!),
          Expanded(
              child: state.when(
                  skipLoadingOnReload: false,
                  skipLoadingOnRefresh: false,
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(l10n.messagesLoadError),
                        TextButton(
                            onPressed: () => ref.invalidate(provider),
                            child: Text(l10n.retry))
                      ])),
                  data: (s) => Column(children: [
                        if (s.error != null)
                          TextButton(
                              onPressed: controller.refresh,
                              child: Text(l10n.messagesSyncError)),
                        Expanded(
                            child: s.messages.isEmpty
                                ? Center(child: Text(l10n.messagesNoThread))
                                : ListView.builder(
                                    key: const ValueKey('chat-message-list'),
                                    controller: _scroll,
                                    reverse: true,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    itemCount:
                                        s.messages.length + (s.hasMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == s.messages.length) {
                                        return Center(
                                            child: TextButton(
                                                onPressed: s.loadingMore
                                                    ? null
                                                    : () => controller.refresh(
                                                        older: true),
                                                child:
                                                    Text(l10n.messagesOlder)));
                                      }
                                      final m = s.messages[index];
                                      final dayStart =
                                          index == s.messages.length - 1 ||
                                              !sameMessageDay(m.sentAt,
                                                  s.messages[index + 1].sentAt);
                                      return Column(
                                          key: ValueKey('message-${m.id}'),
                                          children: [
                                            if (dayStart)
                                              Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  child: Chip(
                                                      label: Text(messageDay(
                                                          context, m.sentAt)))),
                                            ChatMessageBubble(message: m),
                                          ]);
                                    })),
                      ]))),
          if (state.hasValue)
            ChatInputBar(
                sending: state.asData!.value.sending,
                onSend: (text) async {
                  final sent = await controller.send(text);
                  if (mounted && sent && _scroll.hasClients) _scroll.jumpTo(0);
                  return sent;
                }),
        ]));
  }
}
