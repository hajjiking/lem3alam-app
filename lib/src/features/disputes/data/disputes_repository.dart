import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dispute_draft.dart';

abstract interface class DisputesRepository {
  Future<void> submit(DisputeDraft draft);
}

final disputesRepositoryProvider =
    Provider<DisputesRepository>((ref) => MockDisputesRepository());

/// Development adapter only: replace with an authenticated disputes API.
class MockDisputesRepository implements DisputesRepository {
  @override
  Future<void> submit(DisputeDraft draft) async {
    if (!draft.isValid) throw StateError('Invalid dispute');
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }
}
