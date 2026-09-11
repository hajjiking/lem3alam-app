import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../domain/dispute_draft.dart';
import 'dispute_fields.dart';
import 'dispute_summary_row.dart';
import 'evidence_thumbnail.dart';

class DisputeReviewStep extends StatelessWidget {
  const DisputeReviewStep(
      {super.key,
      required this.draft,
      required this.taskCard,
      required this.onEdit});
  final DisputeDraft draft;
  final Widget taskCard;
  final ValueChanged<int> onEdit;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Card(
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.description_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(l.disputeSummary,
                          style: Theme.of(context).textTheme.titleMedium)),
                  TextButton(
                      onPressed: () => onEdit(0), child: Text(l.disputeEdit))
                ]),
                taskCard,
                DisputeSummaryRow(
                    label: l.disputeType,
                    value: disputeTypeLabel(context, draft.disputeType!)),
                const Divider(height: 1),
                DisputeSummaryRow(
                    label: l.disputeAgainstLabel,
                    value:
                        '${draft.againstName}\n${draft.againstRole == 'client' ? l.client : l.tasker}'),
                const Divider(height: 1),
                DisputeSummaryRow(
                    label: l.disputeSubject, value: draft.subject),
                const Divider(height: 1),
                DisputeSummaryRow(
                    label: l.disputeDescription, value: draft.description),
                if (draft.additionalInfo.isNotEmpty)
                  DisputeSummaryRow(
                      label: l.disputeNotes, value: draft.additionalInfo)
              ]))),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: Text(l.disputeAttachments(draft.evidenceFiles.length))),
        TextButton(onPressed: () => onEdit(1), child: Text(l.disputeEdit))
      ]),
      Wrap(spacing: 12, runSpacing: 12, children: [
        for (final file in draft.evidenceFiles) EvidenceThumbnail(file: file)
      ]),
      const SizedBox(height: 20),
      Text(l.disputeMock,
          style:
              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
    ]);
  }
}
