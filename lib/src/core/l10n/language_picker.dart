import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n.dart';
import 'locale_controller.dart';

Future<void> showLanguagePicker(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return const _LanguagePickerSheet();
    },
  );
}

class _LanguagePickerSheet extends ConsumerWidget {
  const _LanguagePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeControllerProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.lang,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _LocaleTile(
              selected: locale.languageCode == 'ar',
              title: l10n.langAr,
              onTap: () async {
                await ref.read(localeControllerProvider.notifier).setLocale(const Locale('ar'));
                if (context.mounted) Navigator.pop(context);
              },
            ),
            _LocaleTile(
              selected: locale.languageCode == 'en',
              title: l10n.langEn,
              onTap: () async {
                await ref.read(localeControllerProvider.notifier).setLocale(const Locale('en'));
                if (context.mounted) Navigator.pop(context);
              },
            ),
            _LocaleTile(
              selected: locale.languageCode == 'fr',
              title: l10n.langFr,
              onTap: () async {
                await ref.read(localeControllerProvider.notifier).setLocale(const Locale('fr'));
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LocaleTile extends StatelessWidget {
  const _LocaleTile({
    required this.selected,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}

