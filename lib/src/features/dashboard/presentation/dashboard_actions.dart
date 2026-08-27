import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/language_picker.dart';
import '../../../core/ui/app_theme.dart';
import '../../../routing/app_router.dart';
import '../../auth/presentation/auth_controller.dart';

void showDashboardFeatureNotice(BuildContext context, String feature) {
  final l10n = context.l10n;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(l10n.dashboardFeatureUnavailable(feature))),
    );
}

void openDashboardProfile(BuildContext context, int? userId, bool isTasker) {
  if (isTasker && userId != null) {
    context.goNamed(
      AppRouteNames.taskerProfile,
      pathParameters: {'id': userId.toString()},
    );
    return;
  }
  showDashboardFeatureNotice(context, context.l10n.dashboardProfile);
}

Future<void> showDashboardMenu(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final themeModeNotifier = ref.read(themeModeControllerProvider.notifier);
  final isDark = themeModeNotifier.effectiveBrightness == Brightness.dark;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(l10n.languageAction),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(sheetContext).pop();
              showLanguagePicker(context);
            },
          ),
          ListTile(
            leading: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            title: Text(
              isDark ? l10n.dashboardLightMode : l10n.dashboardDarkMode,
            ),
            onTap: () {
              Navigator.of(sheetContext).pop();
              ref.read(themeModeControllerProvider.notifier).toggle();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: Text(l10n.logout),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.goNamed(AppRouteNames.login);
            },
          ),
        ],
      ),
    ),
  );
}
