import 'package:flutter/material.dart';

class VerificationRowData {
  const VerificationRowData({
    required this.icon,
    required this.label,
    required this.value,
    required this.verified,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool verified;
}

class VerificationRows extends StatelessWidget {
  const VerificationRows({super.key, required this.rows});

  final List<VerificationRowData> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final success = theme.colorScheme.tertiary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(rows[index].icon,
                  color: theme.colorScheme.primary, size: 23),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rows[index].label, style: theme.textTheme.labelLarge),
                    Text(
                      rows[index].value,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: rows[index].verified
                            ? success
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (index != rows.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}
