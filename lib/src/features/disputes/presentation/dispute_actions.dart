import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/networking/api_exception.dart';
import '../data/disputes_repository.dart';

String disputeActionLabel(BuildContext context, String action) {
  final l = context.l10n;
  return switch (action) {
    'propose' => l.disputePropose,
    'appeal' => l.disputeAppeal,
    'accept' => l.disputeAccept,
    'request_change' => l.disputeRequestChange,
    'decide' => l.disputeDecide,
    _ => action,
  };
}

class DisputeActions extends ConsumerStatefulWidget {
  const DisputeActions(
      {super.key, required this.dispute, required this.onUpdated});
  final DisputeRecord dispute;
  final VoidCallback onUpdated;
  @override
  ConsumerState<DisputeActions> createState() => _DisputeActionsState();
}

class _DisputeActionsState extends ConsumerState<DisputeActions> {
  bool busy = false;
  Future<void> respond(String action) async {
    final message = await showDialog<String>(
        context: context, builder: (_) => _ResponseDialog(action: action));
    if (message == null || !mounted) return;
    setState(() => busy = true);
    try {
      await ref
          .read(disputesRepositoryProvider)
          .act(widget.dispute.id, action, message, widget.dispute.version);
      if (mounted) widget.onUpdated();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error is ApiException
                ? localizeApiException(context, error)
                : context.l10n.disputeFailed)));
        if (error is ApiException &&
            (error.statusCode == 409 || error.statusCode == 403)) {
          widget.onUpdated();
        }
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final d = widget.dispute;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 12),
      Text(
          switch (d.workflowState) {
            'awaiting_acceptance' => l.disputeWaitingAcceptance,
            'escalated' => l.disputeEscalated,
            'resolved' => l.disputeResolved,
            _ => l.disputeWaitingResponse
          },
          style: Theme.of(context).textTheme.titleSmall),
      if (d.workflowState != 'resolved') ...[
        const SizedBox(height: 8),
        Text(l.disputeWorkflowHelp)
      ],
      if (d.history.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text(l.disputeHistory, style: Theme.of(context).textTheme.titleSmall)
      ],
      for (final entry in d.history)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  '${entry['actor_name'] ?? ''} · ${disputeActionLabel(context, entry['action'] as String)}',
                  style: Theme.of(context).textTheme.labelLarge),
              if ((entry['message'] as String? ?? '').isNotEmpty)
                Text(entry['message'] as String),
            ])),
      if (d.resolution.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(l.disputeDecision, style: Theme.of(context).textTheme.titleSmall),
        Text(d.resolution)
      ],
      if (busy) const LinearProgressIndicator(),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final action in d.allowedActions)
          OutlinedButton(
              onPressed: busy ? null : () => respond(action),
              child: Text(disputeActionLabel(context, action)))
      ]),
    ]);
  }
}

class _ResponseDialog extends StatefulWidget {
  const _ResponseDialog({required this.action});
  final String action;
  @override
  State<_ResponseDialog> createState() => _ResponseDialogState();
}

class _ResponseDialogState extends State<_ResponseDialog> {
  final text = TextEditingController();
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accept = widget.action == 'accept';
    final l = context.l10n;
    return AlertDialog(
        title: Text(disputeActionLabel(context, widget.action)),
        content: accept
            ? Text(l.disputeAcceptConfirm)
            : TextField(
                controller: text,
                autofocus: true,
                maxLength: 2000,
                minLines: 3,
                maxLines: 6,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: l.disputeActionMessage)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          FilledButton(
              onPressed: accept || text.text.trim().isNotEmpty
                  ? () => Navigator.pop(context, text.text.trim())
                  : null,
              child: Text(accept ? l.disputeAccept : l.disputeSendResponse)),
        ]);
  }
}
