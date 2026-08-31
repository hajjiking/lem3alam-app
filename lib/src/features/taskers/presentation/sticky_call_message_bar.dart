import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';

class StickyCallMessageBar extends StatelessWidget {
  const StickyCallMessageBar({
    super.key,
    required this.onCall,
    required this.onMessage,
  });

  final VoidCallback? onCall;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final buttons = <Widget>[
      Expanded(
        child: OutlinedButton.icon(
          onPressed: onCall,
          icon: const Icon(Icons.phone_outlined),
          label: Text(l10n.publicProfileCall),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: FilledButton.icon(
          onPressed: onMessage,
          icon: const Icon(Icons.chat_bubble_outline),
          label: Text(l10n.publicProfileSendMessage),
        ),
      ),
    ];
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      elevation: 10,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: Directionality.of(context) == TextDirection.rtl
              ? buttons.reversed.toList(growable: false)
              : buttons,
        ),
      ),
    );
  }
}
