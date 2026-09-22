import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/client_profile_repository.dart';
import '../domain/client_profile.dart';

final clientProfileControllerProvider =
    AsyncNotifierProvider.autoDispose<ClientProfileController, ClientProfile>(
  ClientProfileController.new,
  retry: (_, __) => null,
);

class ClientProfileController extends AsyncNotifier<ClientProfile> {
  @override
  Future<ClientProfile> build() async {
    ref.watch(
      authControllerProvider.select(
        (auth) => (auth.status, auth.user?.id, auth.user?.role),
      ),
    );
    return ref.watch(clientProfileRepositoryProvider).load();
  }

  Future<ClientProfile> save(ClientProfileUpdate update) async {
    return _mutate(
      () => ref.read(clientProfileRepositoryProvider).update(update),
    );
  }

  Future<ClientProfile> uploadAvatar(ClientAvatarFile file) => _mutate(
        () => ref.read(clientProfileRepositoryProvider).uploadAvatar(file),
      );

  Future<ClientProfile> deleteAvatar() => _mutate(
        () => ref.read(clientProfileRepositoryProvider).deleteAvatar(),
      );

  Future<ClientProfile> _mutate(
    Future<ClientProfile> Function() operation,
  ) async {
    final previous = state.value;
    state = const AsyncLoading<ClientProfile>();
    try {
      final profile = await operation();
      if (!ref.mounted) return profile;
      state = AsyncData(profile);
      final currentUser = ref.read(authControllerProvider).user;
      if (currentUser != null && currentUser.id == profile.id) {
        ref.read(authControllerProvider.notifier).updateUser(
              currentUser.copyWith(
                name: profile.name,
                email: profile.email,
                city: profile.city,
              ),
            );
      }
      return profile;
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
