import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../../dashboard/presentation/dashboard_actions.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key, required this.onSend, required this.sending});
  final Future<bool> Function(String) onSend;
  final bool sending;
  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _text = TextEditingController();
  bool _sending = false;
  bool _failed = false;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || widget.sending || _text.text.trim().isEmpty) return;
    final draft = _text.text;
    setState(() {
      _sending = true;
      _failed = false;
    });
    var sent = false;
    try {
      sent = await widget.onSend(draft);
    } catch (_) {/* Keep the draft. */}
    if (!mounted) return;
    if (sent && _text.text == draft) _text.clear();
    setState(() {
      _sending = false;
      _failed = !sent;
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      top: false,
      child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (_failed)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(context.l10n.messagesSendError,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error))),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  IconButton(
                      tooltip: context.l10n.messagesAttach,
                      onPressed: () => showDashboardFeatureNotice(
                          context, context.l10n.messagesAttach),
                      icon: const Icon(Icons.add)),
                  Expanded(
                      child: TextField(
                          key: const ValueKey('message-composer'),
                          controller: _text,
                          enabled: !widget.sending && !_sending,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 5000,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              hintText: context.l10n.messagesType,
                              counterText: '',
                              isDense: true))),
                  const SizedBox(width: 8),
                  ValueListenableBuilder(
                      valueListenable: _text,
                      builder: (context, value, _) => IconButton.filled(
                          key: const ValueKey('message-send'),
                          tooltip: context.l10n.messagesSend,
                          onPressed: value.text.trim().isEmpty ||
                                  widget.sending ||
                                  _sending
                              ? null
                              : _send,
                          icon: widget.sending || _sending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.send_rounded,
                                  textDirection: TextDirection.ltr))),
                ])
              ]))));
}
