import 'package:flutter/material.dart';

import 'metric_card.dart';

class AdminMetricsGrid extends StatelessWidget {
  const AdminMetricsGrid({
    super.key,
    required this.items,
    required this.detailsLabel,
    required this.onSelected,
  });

  final List<AdminMetricCardData> items;
  final String detailsLabel;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 840
            ? 3
            : width >= 340
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 190,
          ),
          itemBuilder: (context, index) => AdminMetricCard(
            data: items[index],
            detailsLabel: detailsLabel,
            onTap: () => onSelected(index),
          ),
        );
      },
    );
  }
}
