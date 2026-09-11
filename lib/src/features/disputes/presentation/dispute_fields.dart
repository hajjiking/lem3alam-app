import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../domain/dispute_draft.dart';

String disputeTypeLabel(BuildContext context, DisputeType type) {
  final l = context.l10n;
  return switch (type) {
    DisputeType.paymentIssue => l.disputePayment,
    DisputeType.qualityOfWork => l.disputeQuality,
    DisputeType.noShow => l.disputeNoShow,
    DisputeType.communicationIssue => l.disputeCommunication,
    DisputeType.other => l.disputeOther
  };
}

class DisputeTextField extends StatelessWidget {
  const DisputeTextField(
      {super.key,
      required this.label,
      required this.value,
      required this.onChanged,
      this.hint,
      this.limit,
      this.lines = 1});
  final String label, value;
  final String? hint;
  final int? limit;
  final int lines;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextFormField(
          initialValue: value,
          onChanged: onChanged,
          maxLength: limit,
          maxLines: lines,
          decoration: InputDecoration(
              labelText: label, hintText: hint, alignLabelWithHint: true),
          buildCounter: limit == null
              ? null
              : (context,
                      {required currentLength,
                      required isFocused,
                      required maxLength}) =>
                  Text(context.l10n.disputeCounter(currentLength, limit!),
                      style: TextStyle(
                          color: currentLength >=
                                  limit! * DisputeLimits.warningRatio
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant))));
}
