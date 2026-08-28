import 'package:flutter/material.dart';
import '../../../core/ui/app_theme.dart';
import '../../tasks/presentation/task_image_support.dart';
import '../domain/conversation_model.dart';
import 'message_format.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({super.key, this.url, this.online, this.size = 46});
  final String? url;
  final bool? online;
  final double size;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final image = resolveTaskImageUrl(url);
    return SizedBox(
        width: size,
        height: size,
        child: Stack(children: [
          Positioned.fill(
              child: ClipOval(
                  child: ColoredBox(
                      color: scheme.primaryContainer,
                      child: image == null
                          ? Icon(Icons.person_rounded,
                              color: scheme.onPrimaryContainer)
                          : Image.network(image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                  Icons.person_rounded,
                                  color: scheme.onPrimaryContainer))))),
          if (online == true)
            PositionedDirectional(
                bottom: 0,
                end: 0,
                child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: Lem3alamColors.accentGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.surface, width: 2)))),
        ]));
  }
}

class ConversationListTile extends StatelessWidget {
  const ConversationListTile(
      {super.key,
      required this.conversation,
      required this.selected,
      required this.onTap});
  final ConversationModel conversation;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final theme = Theme.of(context);
    return Material(
        color: selected
            ? theme.colorScheme.primaryContainer.withValues(alpha: .45)
            : theme.colorScheme.surface,
        child: InkWell(
            onTap: onTap,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  ContactAvatar(url: c.contactAvatarUrl, online: c.isOnline),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          Expanded(
                              child: Text(c.contactName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800))),
                          const SizedBox(width: 8),
                          Text(conversationTime(context, c.lastMessageTime),
                              style: theme.textTheme.labelSmall)
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                              child: Text(c.lastMessagePreview,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant))),
                          if (c.unreadCount > 0)
                            Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(start: 8),
                                child: Badge(
                                    label: Text('${c.unreadCount}'),
                                    backgroundColor: theme.colorScheme.primary,
                                    textColor: theme.colorScheme.onPrimary))
                        ]),
                      ])),
                ]))));
  }
}
