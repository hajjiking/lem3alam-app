import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/networking/api_exception.dart';
import '../data/user_reports_repository.dart';
import '../domain/user_report.dart';

Future<bool> showReportUserSheet(
  BuildContext context,
  WidgetRef ref, {
  required int reportedUserId,
  int? taskId,
  int? messageId,
}) async {
  final submitted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _ReportUserSheet(
      reportedUserId: reportedUserId,
      taskId: taskId,
      messageId: messageId,
    ),
  );
  if (submitted == true && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.reportSubmitted)));
  }
  return submitted == true;
}

class _ReportUserSheet extends ConsumerStatefulWidget {
  const _ReportUserSheet({
    required this.reportedUserId,
    this.taskId,
    this.messageId,
  });

  final int reportedUserId;
  final int? taskId;
  final int? messageId;

  @override
  ConsumerState<_ReportUserSheet> createState() => _ReportUserSheetState();
}

class _ReportUserSheetState extends ConsumerState<_ReportUserSheet> {
  final _details = TextEditingController();
  ReportReason? _reason;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reason == null || _submitting) {
      setState(() => _error = context.l10n.reportChooseReason);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(userReportsRepositoryProvider).submit(UserReportDraft(
            reportedUserId: widget.reportedUserId,
            taskId: widget.taskId,
            messageId: widget.messageId,
            reason: _reason!,
            details: _details.text,
          ));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = localizeApiException(context, error));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.errUnknown);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.reportUserTitle,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(l.reportUserExplanation),
          const SizedBox(height: 16),
          DropdownButtonFormField<ReportReason>(
            value: _reason,
            decoration: InputDecoration(labelText: l.reportReason),
            items: [
              for (final reason in ReportReason.values)
                DropdownMenuItem(
                  value: reason,
                  child: Text(_label(reason)),
                ),
            ],
            onChanged: _submitting
                ? null
                : (value) => setState(() {
                      _reason = value;
                      _error = null;
                    }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _details,
            enabled: !_submitting,
            minLines: 3,
            maxLines: 6,
            maxLength: 5000,
            decoration: InputDecoration(labelText: l.reportDetails),
          ),
          if (_error != null)
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.flag_outlined),
            label: Text(l.reportSubmit),
          ),
        ],
      ),
    );
  }

  String _label(ReportReason reason) => switch (reason) {
        ReportReason.harassment => context.l10n.reportHarassment,
        ReportReason.spam => context.l10n.reportSpam,
        ReportReason.fraud => context.l10n.reportFraud,
        ReportReason.inappropriateContent => context.l10n.reportInappropriate,
        ReportReason.other => context.l10n.reportOther,
      };
}
