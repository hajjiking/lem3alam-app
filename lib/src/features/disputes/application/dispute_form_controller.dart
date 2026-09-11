import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dispute_draft.dart';
import '../data/disputes_repository.dart';

final disputeFormProvider =
    NotifierProvider.autoDispose<DisputeFormController, DisputeFormState>(
        DisputeFormController.new);

class DisputeFormState {
  const DisputeFormState(
      {this.draft,
      this.step = 0,
      this.submitting = false,
      this.failed = false});
  final DisputeDraft? draft;
  final int step;
  final bool submitting, failed;
}

enum EvidenceError { count, size, format }

class DisputeFormController extends Notifier<DisputeFormState> {
  @override
  DisputeFormState build() => const DisputeFormState();
  void initialize(DisputeDraft draft) => state = DisputeFormState(draft: draft);
  void update(DisputeDraft draft) {
    if (!state.submitting && state.step < 3) {
      state = DisputeFormState(draft: draft, step: state.step);
    }
  }

  void goTo(int step) {
    if (state.submitting || state.step == 3 || step < 0 || step > 2) return;
    if (step > 0 && state.draft?.isValid != true) return;
    state = DisputeFormState(draft: state.draft, step: step);
  }

  EvidenceError? addFiles(List<EvidenceFile> files) {
    final draft = state.draft;
    if (draft == null || state.submitting || state.step == 3) return null;
    // Validate the entire batch before mutation: no silently dropped evidence.
    if (draft.evidenceFiles.length + files.length > DisputeLimits.maxFiles) {
      return EvidenceError.count;
    }
    if (files.any((f) => f.bytes.length > DisputeLimits.maxBytes)) {
      return EvidenceError.size;
    }
    if (files.any((f) => !['jpg', 'jpeg', 'png', 'pdf']
        .contains(f.fileName.split('.').last.toLowerCase()))) {
      return EvidenceError.format;
    }
    update(draft.copyWith(evidenceFiles: [...draft.evidenceFiles, ...files]));
    return null;
  }

  void removeFile(EvidenceFile file) => update(state.draft!.copyWith(
      evidenceFiles:
          state.draft!.evidenceFiles.where((f) => f != file).toList()));
  Future<void> submit() async {
    final draft = state.draft;
    if (state.submitting || state.step != 2 || draft?.isValid != true) return;
    state = DisputeFormState(draft: draft, step: 2, submitting: true);
    try {
      await ref.read(disputesRepositoryProvider).submit(draft!);
      if (ref.mounted) {
        state = const DisputeFormState(
            step: 3); // Clear sensitive draft and evidence on success.
      }
    } catch (_) {
      if (ref.mounted) {
        state = DisputeFormState(draft: draft, step: 2, failed: true);
      }
    }
  }
}
