import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/features/disputes/application/dispute_form_controller.dart';
import 'package:lem3alam_mobile/src/features/disputes/data/disputes_repository.dart';
import 'package:lem3alam_mobile/src/features/disputes/domain/dispute_draft.dart';

class TestRepository implements DisputesRepository {
  bool fail = false;
  int calls = 0;
  @override
  Future<void> submit(DisputeDraft draft) async {
    calls++;
    if (fail) throw StateError('offline');
  }
}

void main() {
  late ProviderContainer container;
  late DisputeFormController controller;
  late TestRepository repository;
  const draft = DisputeDraft(
      taskId: 10,
      againstUserId: 20,
      againstName: 'Counterpart',
      disputeType: DisputeType.paymentIssue,
      subject: 'Payment',
      description: 'Charged twice');
  setUp(() {
    repository = TestRepository();
    container = ProviderContainer(
        overrides: [disputesRepositoryProvider.overrideWithValue(repository)]);
    container.listen(disputeFormProvider, (_, __) {});
    controller = container.read(disputeFormProvider.notifier);
    controller.initialize(draft);
  });
  tearDown(() => container.dispose());
  EvidenceFile file(String name, [int size = 10]) => EvidenceFile(
      localPathOrUrl: name,
      fileName: name,
      fileType: EvidenceFileType.document,
      bytes: Uint8List(size));
  test('required fields gate navigation and editing preserves draft', () {
    controller.initialize(const DisputeDraft(taskId: 10));
    controller.goTo(1);
    expect(container.read(disputeFormProvider).step, 0);
    controller.initialize(draft);
    controller.goTo(2);
    controller.goTo(0);
    expect(container.read(disputeFormProvider).draft!.description,
        'Charged twice');
  });
  test('evidence batches enforce count, size and formats atomically', () {
    expect(
        controller.addFiles(List.generate(5, (i) => file('$i.pdf'))), isNull);
    expect(controller.addFiles([file('six.pdf')]), EvidenceError.count);
    expect(container.read(disputeFormProvider).draft!.evidenceFiles.length, 5);
    controller.initialize(draft);
    expect(controller.addFiles([file('big.pdf', DisputeLimits.maxBytes + 1)]),
        EvidenceError.size);
    expect(controller.addFiles([file('bad.exe')]), EvidenceError.format);
    expect(container.read(disputeFormProvider).draft!.evidenceFiles, isEmpty);
    final accepted = file('ok.pdf', DisputeLimits.maxBytes);
    expect(controller.addFiles([accepted]), isNull);
    controller.removeFile(accepted);
    expect(container.read(disputeFormProvider).draft!.evidenceFiles, isEmpty);
  });
  test('successful submission clears draft and prevents revisiting form',
      () async {
    controller.goTo(2);
    final submission = controller.submit();
    await controller.submit();
    await submission;
    expect(repository.calls, 1);
    expect(container.read(disputeFormProvider).draft, isNull);
    expect(container.read(disputeFormProvider).step, 3);
    controller.goTo(0);
    expect(container.read(disputeFormProvider).step, 3);
  });
  test('failed submission retains evidence and supports retry', () async {
    repository.fail = true;
    controller.addFiles([file('receipt.pdf')]);
    controller.goTo(2);
    await controller.submit();
    expect(container.read(disputeFormProvider).failed, isTrue);
    expect(container.read(disputeFormProvider).draft!.evidenceFiles.length, 1);
    repository.fail = false;
    await controller.submit();
    expect(container.read(disputeFormProvider).step, 3);
  });
}
