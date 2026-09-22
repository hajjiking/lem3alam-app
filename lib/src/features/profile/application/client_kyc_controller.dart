import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/client_kyc_repository.dart';
import '../domain/client_kyc.dart';

final clientKycControllerProvider =
    AsyncNotifierProvider.autoDispose<ClientKycController, KycOverview>(
  ClientKycController.new,
  retry: (_, __) => null,
);

class ClientKycController extends AsyncNotifier<KycOverview> {
  @override
  Future<KycOverview> build() {
    ref.watch(authControllerProvider.select(
      (auth) => (auth.status, auth.user?.id, auth.user?.role),
    ));
    return ref.watch(clientKycRepositoryProvider).load();
  }

  Future<void> submit(KycSubmission submission) async {
    final previous = state.value;
    state = const AsyncLoading<KycOverview>();
    try {
      state = AsyncData(
        await ref.read(clientKycRepositoryProvider).submit(submission),
      );
    } catch (error, stackTrace) {
      if (ref.mounted) {
        state = previous == null
            ? AsyncError(error, stackTrace)
            : AsyncData(previous);
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
