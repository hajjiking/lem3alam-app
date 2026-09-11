import 'package:flutter/material.dart';

class DisputeSummaryRow extends StatelessWidget {
  const DisputeSummaryRow(
      {super.key, required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant))),
        const SizedBox(width: 12),
        Expanded(flex: 3, child: Text(value))
      ]));
}
