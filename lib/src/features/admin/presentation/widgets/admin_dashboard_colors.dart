import 'package:flutter/material.dart';

import '../../../../core/ui/app_theme.dart';
import '../../domain/admin_dashboard_models.dart';

Color adminDashboardColor(BuildContext context, AdminColorKey key) {
  final theme = Theme.of(context);
  final tokens = theme.extension<Lem3alamThemeTokens>()!;
  return switch (key) {
    AdminColorKey.primary => theme.colorScheme.primary,
    AdminColorKey.success => theme.colorScheme.tertiary,
    AdminColorKey.purple => tokens.accentPurple,
    AdminColorKey.warning => tokens.warning,
    AdminColorKey.info => tokens.info,
    AdminColorKey.error => theme.colorScheme.error,
  };
}

Color adminDashboardTint(BuildContext context, Color color) {
  final alpha = Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.10;
  return color.withValues(alpha: alpha);
}
