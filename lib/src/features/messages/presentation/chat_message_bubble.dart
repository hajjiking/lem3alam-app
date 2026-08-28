import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi;
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_theme.dart';
import '../domain/conversation_model.dart';
import 'message_format.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});
  final ChatMessageModel message;
  @override
  Widget build(BuildContext context) {
    final m = message;
    final theme = Theme.of(context);
    final foreground =
        m.isMe ? Lem3alamColors.surface : theme.colorScheme.onSurface;
    final status = switch (m.status) {
      MessageStatus.sent => context.l10n.messagesSent,
      MessageStatus.delivered => context.l10n.messagesDelivered,
      MessageStatus.read => context.l10n.messagesRead
    };
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Align(
          alignment: m.isMe
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
              widthFactor: .84,
              child: Align(
                alignment: m.isMe
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: m.isMe
                            ? Lem3alamColors.primaryBlue
                            : theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadiusDirectional.only(
                            topStart: const Radius.circular(18),
                            topEnd: const Radius.circular(18),
                            bottomStart: Radius.circular(m.isMe ? 18 : 4),
                            bottomEnd: Radius.circular(m.isMe ? 4 : 18))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SelectableText(m.text,
                              textDirection:
                                  Bidi.detectRtlDirectionality(m.text)
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(color: foreground)),
                          const SizedBox(height: 8),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(messageTime(context, m.sentAt),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                        color:
                                            foreground.withValues(alpha: .85))),
                                if (m.isMe) ...[
                                  const SizedBox(width: 5),
                                  Tooltip(
                                      message: status,
                                      child: Icon(
                                          m.status == MessageStatus.sent
                                              ? Icons.check
                                              : Icons.done_all,
                                          size: 16,
                                          color: foreground,
                                          semanticLabel: status))
                                ],
                              ]),
                        ])),
              )),
        ));
  }
}
