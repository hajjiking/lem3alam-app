import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';

class PublicProfileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PublicProfileAppBar({
    super.key,
    required this.onBack,
    required this.onShare,
  });

  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: Text(l10n.publicProfileTitle),
      leading: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onBack,
        icon: const BackButtonIcon(),
      ),
      actions: [
        IconButton(
          tooltip: l10n.profileShare,
          onPressed: onShare,
          icon: const Icon(Icons.share_outlined),
        ),
        PopupMenuButton<String>(
          tooltip: MaterialLocalizations.of(context).showMenuTooltip,
          iconColor: Colors.white,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'report',
              child: Text(l10n.publicProfileReport),
            ),
            PopupMenuItem(
              value: 'block',
              child: Text(l10n.publicProfileBlock),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
