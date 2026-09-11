import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../domain/dispute_draft.dart';
import 'dispute_fields.dart';
import 'evidence_thumbnail.dart';
import 'upload_dropzone.dart';

class DisputeEvidenceStep extends StatelessWidget {
  const DisputeEvidenceStep(
      {super.key,
      required this.draft,
      required this.onChanged,
      required this.onPick,
      required this.onRemove});
  final DisputeDraft draft;
  final ValueChanged<DisputeDraft> onChanged;
  final VoidCallback? onPick;
  final ValueChanged<EvidenceFile> onRemove;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l.disputeUpload, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      Text(l.disputeUploadHelp(
          DisputeLimits.maxFiles, DisputeLimits.maxMegabytes)),
      const SizedBox(height: 16),
      UploadDropzone(onTap: onPick),
      const SizedBox(height: 24),
      Wrap(spacing: 12, runSpacing: 12, children: [
        for (final file in draft.evidenceFiles)
          EvidenceThumbnail(file: file, onRemove: () => onRemove(file)),
        if (draft.evidenceFiles.length < DisputeLimits.maxFiles)
          SizedBox(
              width: 96,
              height: 108,
              child: UploadDropzone(onTap: onPick, small: true))
      ]),
      const SizedBox(height: 16),
      DisputeTextField(
          label: l.disputeNotes,
          hint: l.disputeNotesHint,
          value: draft.additionalInfo,
          lines: 4,
          limit: DisputeLimits.notesLength,
          onChanged: (v) => onChanged(draft.copyWith(additionalInfo: v)))
    ]);
  }
}
