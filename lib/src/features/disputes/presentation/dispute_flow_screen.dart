import '../../../core/l10n/api_error_localizer.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/ui/detail_page_header.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/widgets/dashboard_bottom_navigation.dart';
import '../../messages/domain/conversation_model.dart';
import '../../messages/presentation/task_context_card.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/tasks_controller.dart';
import '../application/dispute_form_controller.dart';
import '../domain/dispute_draft.dart';
import 'dispute_details_step.dart';
import 'dispute_evidence_step.dart';
import 'dispute_review_step.dart';
import 'dispute_step_indicator.dart';
import 'dispute_submitted_step.dart';

class DisputeFlowScreen extends StatelessWidget {
  const DisputeFlowScreen({super.key, required this.taskId});
  final int taskId;
  @override
  Widget build(BuildContext context) => ProviderScope(
      overrides: [disputeFormProvider.overrideWith(DisputeFormController.new)],
      child: _DisputeFlow(taskId: taskId));
}

class _DisputeFlow extends ConsumerStatefulWidget {
  const _DisputeFlow({required this.taskId});
  final int taskId;
  @override
  ConsumerState<_DisputeFlow> createState() => _DisputeFlowState();
}

class _DisputeFlowState extends ConsumerState<_DisputeFlow> {
  bool _initialized = false,
      _picking = false,
      _exiting = false,
      _asking = false;
  Future<void> _back() async {
    final state = ref.read(disputeFormProvider);
    if (state.submitting || _asking) return;
    if (state.step == 3) {
      context.go('/dashboard');
      return;
    }
    if (state.step > 0) {
      ref.read(disputeFormProvider.notifier).goTo(state.step - 1);
      return;
    }
    if (state.draft?.isDirty == true) {
      _asking = true;
      final l = context.l10n;
      final discard = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text(l.disputeDiscard),
                  content: Text(l.disputeDiscardBody),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l.cancel)),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l.disputeDiscardAction))
                  ]));
      _asking = false;
      if (discard != true || !mounted) return;
    }
    setState(() => _exiting = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/tasks');
        }
      }
    });
  }

  Future<void> _pick() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
          allowMultiple: true,
          withReadStream: true);
      if (!mounted || result == null) return;
      final files = result.files;
      final draft = ref.read(disputeFormProvider).draft;
      if (draft == null) return;
      if (draft.evidenceFiles.length + files.length > DisputeLimits.maxFiles ||
          files.any((f) => f.size > DisputeLimits.maxBytes)) {
        _message(context.l10n.disputeFileError(
            DisputeLimits.maxFiles, DisputeLimits.maxMegabytes));
        return;
      }
      final evidence = <EvidenceFile>[];
      for (final file in files) {
        // Bound memory even if a provider reports an incorrect file size.
        final bytes = BytesBuilder(copy: false);
        await for (final chunk in file.readStream ?? file.xFile.openRead()) {
          if (bytes.length + chunk.length > DisputeLimits.maxBytes) {
            if (mounted) {
              _message(context.l10n.disputeFileError(
                  DisputeLimits.maxFiles, DisputeLimits.maxMegabytes));
            }
            return;
          }
          bytes.add(chunk);
        }
        evidence.add(EvidenceFile(
            localPathOrUrl: file.path ?? file.name,
            fileName: file.name,
            fileType: file.extension?.toLowerCase() == 'pdf'
                ? EvidenceFileType.document
                : EvidenceFileType.image,
            bytes: bytes.takeBytes()));
      }
      if (!mounted) return;
      final error = ref.read(disputeFormProvider.notifier).addFiles(evidence);
      if (error != null) {
        _message(context.l10n.disputeFileError(
            DisputeLimits.maxFiles, DisputeLimits.maxMegabytes));
      }
    } catch (_) {
      if (mounted) _message(context.l10n.disputePickFailed);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _message(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
  Widget _taskCard(Task task) => TaskContextCard(
      task: ConversationTaskContext.fromJson({
        'id': task.id,
        'title': task.title,
        'thumbnail_url': task.primaryImageSource,
        'location': task.city
      }),
      category: task
          .localizedCategoryName(Localizations.localeOf(context).languageCode),
      dateLabel: task.deadline == null
          ? null
          : DateFormat.yMMMd(Localizations.localeOf(context).toString())
              .format(task.deadline!),
      interactive: false);
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = ref.watch(disputeFormProvider);
    final controller = ref.read(disputeFormProvider.notifier);
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));
    final user = ref.watch(authControllerProvider).user;
    final task = taskAsync.asData?.value;
    final eligible = task != null &&
        ((user?.isClient == true &&
                task.clientId == user?.id &&
                task.assignedTaskerId != null) ||
            (user?.isTasker == true &&
                task.assignedTaskerId == user?.id &&
                task.clientId != null));
    if (!_initialized && eligible) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        controller.initialize(DisputeDraft(
            taskId: task.id,
            againstUserId:
                user!.isClient ? task.assignedTaskerId : task.clientId,
            againstName:
                (user.isClient ? task.assignedTaskerName : task.clientName) ??
                    (user.isClient ? l.tasker : l.client),
            againstRole: user.isClient ? 'tasker' : 'client'));
      });
    }
    final titles = [
      l.disputeTitle,
      l.disputeEvidenceTitle,
      l.disputeReviewTitle
    ];
    final subtitles = [
      l.disputeSubtitle,
      l.disputeEvidenceSubtitle,
      l.disputeReviewSubtitle
    ];
    return PopScope(
        canPop: _exiting,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _back();
        },
        child: Scaffold(
            appBar: DetailPageHeader(
                showBackButton: state.step != 3,
                onBack: state.submitting ? null : _back),
            bottomNavigationBar: state.step == 3
                ? DashboardBottomNavigation(
                    selectedIndex: 0,
                    homeLabel: l.home,
                    tasksLabel: l.tasks,
                    messagesLabel: l.dashboardMessages,
                    earningsLabel: user?.isClient == true
                        ? l.clientDashboardPayments
                        : l.dashboardEarnings,
                    profileLabel: l.dashboardProfile,
                    postTaskLabel:
                        user?.isClient == true ? l.dashboardPostTask : null,
                    onSelected: (i) {
                      final routes = user?.isClient == true
                          ? [
                              '/dashboard',
                              '/tasks',
                              '/tasks/create',
                              '/messages',
                              '/payments'
                            ]
                          : [
                              '/dashboard',
                              '/tasks',
                              '/messages',
                              '/earnings',
                              '/taskers/${user?.id}'
                            ];
                      context.go(routes[i]);
                    })
                : null,
            body: SafeArea(
                child: Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: taskAsync.when(
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (_, __) => Center(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                      Text(l.unableToLoad),
                                      TextButton(
                                          onPressed: () => ref.invalidate(
                                              taskDetailProvider(
                                                  widget.taskId)),
                                          child: Text(l.retry))
                                    ])),
                            data: (task) {
                              if (!eligible) {
                                return Center(
                                    child: Text(l.disputeUnavailable));
                              }
                              if (state.step != 3 && state.draft == null) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return ListView(
                                  padding: const EdgeInsets.all(20),
                                  children: [
                                    if (state.step == 3)
                                      const DisputeSubmittedStep()
                                    else ...[
                                      Text(titles[state.step],
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text(subtitles[state.step]),
                                      DisputeStepIndicator(step: state.step),
                                      AbsorbPointer(
                                          absorbing: state.submitting,
                                          child: switch (state.step) {
                                            0 => DisputeDetailsStep(
                                                draft: state.draft!,
                                                onChanged: controller.update,
                                                taskCard: _taskCard(task)),
                                            1 => DisputeEvidenceStep(
                                                draft: state.draft!,
                                                onChanged: controller.update,
                                                onPick: _picking ? null : _pick,
                                                onRemove:
                                                    controller.removeFile),
                                            _ => DisputeReviewStep(
                                                draft: state.draft!,
                                                taskCard: _taskCard(task),
                                                onEdit: controller.goTo),
                                          }),
                                      if (state.failed)
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 16),
                                            child: Text(
                                                state.error == null
                                                    ? l.disputeFailed
                                                    : localizeApiException(
                                                        context, state.error!),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error))),
                                      const SizedBox(height: 28),
                                      Row(children: [
                                        if (state.step > 0) ...[
                                          Expanded(
                                              child: OutlinedButton(
                                                  onPressed: state.submitting
                                                      ? null
                                                      : _back,
                                                  child: Text(l.disputeBack))),
                                          const SizedBox(width: 12)
                                        ],
                                        Expanded(
                                            flex: 2,
                                            child: FilledButton(
                                                onPressed: state.submitting ||
                                                        _picking ||
                                                        !state.draft!.isValid
                                                    ? null
                                                    : () {
                                                        if (state.step == 2) {
                                                          controller.submit();
                                                        } else {
                                                          controller.goTo(
                                                              state.step + 1);
                                                        }
                                                      },
                                                child: state.submitting
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 2))
                                                    : Text(
                                                        state.step == 0
                                                            ? l
                                                                .disputeNextEvidence
                                                            : state.step == 1
                                                                ? l
                                                                    .disputeNextReview
                                                                : l
                                                                    .disputeSubmit,
                                                        textAlign:
                                                            TextAlign.center)))
                                      ])
                                    ]
                                  ]);
                            }))))));
  }
}
