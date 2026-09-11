import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../domain/dispute_draft.dart';
import 'dispute_fields.dart';

class DisputeDetailsStep extends StatelessWidget {
  const DisputeDetailsStep(
      {super.key,
      required this.draft,
      required this.onChanged,
      required this.taskCard});
  final DisputeDraft draft;
  final ValueChanged<DisputeDraft> onChanged;
  final Widget taskCard;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      taskCard,
      const SizedBox(height: 16),
      DropdownButtonFormField<DisputeType>(
          value: draft.disputeType,
          isExpanded: true,
          decoration: InputDecoration(labelText: '${l.disputeType} *'),
          items: DisputeType.values
              .map((t) => DropdownMenuItem(
                  value: t, child: Text(disputeTypeLabel(context, t))))
              .toList(),
          onChanged: (t) => onChanged(draft.copyWith(disputeType: t))),
      const SizedBox(height: 16),
      Text('${l.disputeAgainst} *'),
      Card(
          child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(draft.againstName),
              subtitle:
                  Text(draft.againstRole == 'client' ? l.client : l.tasker),
              trailing: const Icon(Icons.lock_outline, size: 18))),
      DisputeTextField(
          label: '${l.disputeSubject} *',
          value: draft.subject,
          limit: DisputeLimits.subjectLength,
          onChanged: (v) => onChanged(draft.copyWith(subject: v))),
      DisputeTextField(
          label: '${l.disputeDescription} *',
          hint: l.disputeDescriptionHint,
          value: draft.description,
          limit: DisputeLimits.descriptionLength,
          lines: 5,
          onChanged: (v) => onChanged(draft.copyWith(description: v))),
    ]);
  }
}
