import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import 'dashboard_promo.dart';

class ClientPromoBanner extends StatelessWidget {
  const ClientPromoBanner({super.key, required this.onPostTask});

  final VoidCallback onPostTask;

  @override
  Widget build(BuildContext context) => DashboardPromoBanner(
        title: context.l10n.clientDashboardPromoTitle,
        subtitle: context.l10n.clientDashboardPromoSubtitle,
        actionLabel: context.l10n.dashboardPostTask,
        actionIcon: Icons.add_rounded,
        illustrationAsset: 'assets/artisan_cutout.png',
        onTap: onPostTask,
      );
}
