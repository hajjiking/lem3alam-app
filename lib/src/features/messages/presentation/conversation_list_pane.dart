import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n.dart';
import '../application/conversations_controller.dart';
import '../domain/conversation_model.dart';
import 'conversation_list_tile.dart';

String conversationFilterLabel(
        BuildContext context, ConversationFilter filter) =>
    switch (filter) {
      ConversationFilter.all => context.l10n.all,
      ConversationFilter.unread => context.l10n.messagesUnread,
      ConversationFilter.archived => context.l10n.messagesArchived,
    };

class ConversationListPane extends ConsumerWidget {
  const ConversationListPane(
      {super.key, required this.onSelect, this.selected});
  final ValueChanged<ConversationModel> onSelect;
  final ChatKey? selected;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(conversationsControllerProvider.notifier);
    return ref.watch(conversationsControllerProvider).when(
          skipLoadingOnReload: false,
          skipLoadingOnRefresh: false,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.messagesLoadError),
            TextButton(onPressed: controller.refresh, child: Text(l10n.retry))
          ])),
          data: (state) => Column(children: [
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (final filter in ConversationFilter.values)
                    Semantics(
                        selected: state.filter == filter,
                        child: InkWell(
                            onTap: () => controller.filter(filter),
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 16),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 3,
                                            color: state.filter == filter
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .surface))),
                                child: Row(children: [
                                  Text(
                                      conversationFilterLabel(context, filter)),
                                  const SizedBox(width: 6),
                                  Badge(
                                      label: Text('${state.count(filter)}'),
                                      backgroundColor: state.filter == filter
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                      textColor: state.filter == filter
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)
                                ])))),
                ])),
            if (state.filter == ConversationFilter.archived)
              Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(l10n.messagesLocalArchive,
                      style: Theme.of(context).textTheme.bodySmall)),
            if (state.error != null)
              TextButton(
                  onPressed: controller.refresh,
                  child: Text(l10n.messagesSyncError)),
            Expanded(
                child: RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            state.visible.isEmpty ? 1 : state.visible.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (context, index) {
                          if (state.visible.isEmpty) {
                            return Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(state.items.isEmpty
                                    ? l10n.messagesEmpty
                                    : l10n.messagesNoMatch));
                          }
                          final c = state.visible[index];
                          return ConversationListTile(
                              key: ValueKey(c.id),
                              conversation: c,
                              selected: selected == c.key,
                              onTap: () => onSelect(c));
                        }))),
          ]),
        );
  }
}
