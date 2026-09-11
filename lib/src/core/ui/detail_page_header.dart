import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'app_theme.dart';

/// Shared branded detail header; confirmation pages omit the leading action.
class DetailPageHeader extends StatelessWidget implements PreferredSizeWidget {
  const DetailPageHeader({super.key, this.onBack, this.showBackButton = true});
  final VoidCallback? onBack;
  final bool showBackButton;
  @override
  Size get preferredSize => const Size.fromHeight(80);
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final tokens = Theme.of(context).extension<Lem3alamThemeTokens>()!;
    return AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        automaticallyImplyLeading: false,
        foregroundColor: c.onPrimary,
        flexibleSpace: DecoratedBox(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [tokens.headerStart, tokens.headerEnd]))),
        leading: showBackButton
            ? IconButton(
                onPressed: onBack,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const BackButtonIcon())
            : null,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.home_work_outlined, size: 36),
          const SizedBox(width: 10),
          Text(context.l10n.appName,
              style: TextStyle(color: c.onPrimary, fontWeight: FontWeight.bold))
        ]));
  }
}
