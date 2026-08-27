import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/networking/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../domain/task.dart';
import 'tasks_controller.dart';

Future<void> showTaskApplicationSheet(BuildContext context, WidgetRef ref,
    {required int taskId}) async {
  final user = ref.read(authControllerProvider).user;
  final messenger = ScaffoldMessenger.of(context);
  final successMessage = context.l10n.applicationSubmitted;
  final submitted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TaskApplicationSheet(taskId: taskId),
  );
  if (submitted != true || !context.mounted) return;
  final currentUser = ref.read(authControllerProvider).user;
  if (currentUser?.id != user?.id || currentUser?.role != user?.role) return;

  // Use the surviving page's ref/messenger, not the closing sheet's context.
  ref.invalidate(taskDetailProvider(taskId));
  ref.invalidate(tasksListControllerProvider);
  ref.invalidate(dashboardControllerProvider);
  if (messenger.mounted) {
    messenger.showSnackBar(SnackBar(content: Text(successMessage)));
  }
}

class _TaskApplicationSheet extends ConsumerStatefulWidget {
  const _TaskApplicationSheet({required this.taskId});
  final int taskId;
  @override
  ConsumerState<_TaskApplicationSheet> createState() =>
      _TaskApplicationSheetState();
}

class _TaskApplicationSheetState extends ConsumerState<_TaskApplicationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _proposal = TextEditingController();
  final _budget = TextEditingController();
  final _duration = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    // A modal future finishes before its exit animation. The controllers must
    // survive until the fields themselves leave the widget tree.
    _proposal.dispose();
    _budget.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;
    final route = ModalRoute.of(context);
    final mutation = ref.read(taskMutationControllerProvider);
    final payload = TaskApplicationPayload(
      proposal: _proposal.text.trim(),
      proposedBudget: double.parse(_budget.text.trim().replaceAll(',', '.')),
      estimatedDuration: _duration.text.trim(),
    );
    setState(() => _submitting = true);
    try {
      await mutation.apply(taskId: widget.taskId, payload: payload);
      // Dismissed sheets remain mounted during their exit animation. A late
      // result must not pop the underlying task detail page.
      if (!mounted || route?.isCurrent != true) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted || route?.isCurrent != true) return;
      setState(() => _submitting = false);
      final message = error is ApiException
          ? localizeApiException(context, error)
          : context.l10n.errUnknown;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(
            16, 8, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.applyToTask,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _proposal,
                maxLines: 4,
                enabled: !_submitting,
                decoration: InputDecoration(
                    labelText: l10n.proposal,
                    prefixIcon: const Icon(Icons.notes_outlined)),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _budget,
                enabled: !_submitting,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    labelText: l10n.proposedBudget,
                    prefixIcon: const Icon(Icons.payments_outlined)),
                validator: (value) {
                  final parsed = double.tryParse(
                      (value ?? '').trim().replaceAll(',', '.'));
                  return parsed == null || !parsed.isFinite || parsed < 0
                      ? l10n.requiredField
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _duration,
                enabled: !_submitting,
                decoration: InputDecoration(
                    labelText: l10n.estimatedDuration,
                    prefixIcon: const Icon(Icons.schedule_outlined)),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.submitApplication),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
