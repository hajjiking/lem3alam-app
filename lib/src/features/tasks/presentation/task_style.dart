import 'package:flutter/material.dart';

import '../../../core/ui/app_theme.dart';

Color taskStatusColor(BuildContext context, String status) => switch (status) {
      'open' => context.appColors.primary,
      'assigned' || 'in_progress' => context.appTokens.warning,
      'completed' => context.appTokens.success,
      'cancelled' => context.appColors.error,
      _ => context.appColors.onSurfaceVariant,
    };

Color taskUrgencyColor(BuildContext context, String urgency) =>
    switch (urgency) {
      'urgent' || 'high' => context.appColors.error,
      'medium' => context.appTokens.warning,
      'low' => context.appTokens.success,
      _ => context.appColors.onSurfaceVariant,
    };
