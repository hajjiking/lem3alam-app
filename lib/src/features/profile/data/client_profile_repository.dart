import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/client_profile.dart';
import 'client_profile_api.dart';

final clientProfileRepositoryProvider =
    Provider<ClientProfileRepository>((ref) {
  return ClientProfileRepository(
    api: ClientProfileApi(ref.watch(apiClientProvider)),
    readAuth: () => ref.read(authControllerProvider),
    expireSession: () =>
        ref.read(authControllerProvider.notifier).expireSession(),
  );
});

class ClientProfileRepository {
  static const maxAvatarBytes = 2 * 1024 * 1024;
  static const allowedAvatarExtensions = {'jpg', 'jpeg', 'png', 'gif'};

  ClientProfileRepository({
    required this.api,
    required this.readAuth,
    required this.expireSession,
  });

  final ClientProfileApi api;
  final AuthState Function() readAuth;
  final Future<void> Function() expireSession;

  Future<ClientProfile> load() => _authenticated(api.getProfile);

  Future<ClientProfile> update(ClientProfileUpdate update) =>
      _authenticated(() => api.updateProfile(update));

  Future<ClientProfile> uploadAvatar(ClientAvatarFile file) async {
    final extension = file.name.split('.').last.toLowerCase();
    if (file.bytes.isEmpty ||
        file.bytes.length > maxAvatarBytes ||
        !allowedAvatarExtensions.contains(extension)) {
      throw const ApiException(message: 'err_invalid_avatar');
    }
    await _authenticatedResponse(() => api.uploadAvatar(file));
    return load();
  }

  Future<ClientProfile> deleteAvatar() async {
    await _authenticatedResponse(api.deleteAvatar);
    return load();
  }

  Future<ClientProfile> _authenticated(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    final response = await _authenticatedResponse(request);
    final requestedUser = readAuth().user!;
    final data = _map(response['data']);
    final profile = ClientProfile.fromJson(data);
    if (profile.id != requestedUser.id) {
      throw const FormatException('Profile owner does not match session');
    }
    return profile;
  }

  Future<Map<String, dynamic>> _authenticatedResponse(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    final requestedUser = readAuth().user;
    if (readAuth().status != AuthStatus.authenticated ||
        requestedUser?.isClient != true) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    try {
      final response = await request();
      final currentUser = readAuth().user;
      if (currentUser?.id != requestedUser!.id ||
          currentUser?.isClient != true) {
        throw const ApiException(statusCode: 403, message: 'err_forbidden');
      }
      return response;
    } on ApiException catch (error) {
      if (error.statusCode == 401 && readAuth().user?.id == requestedUser?.id) {
        await expireSession();
      }
      rethrow;
    }
  }

  static Map<String, dynamic> _map(dynamic value) => value is Map
      ? value.map((key, value) => MapEntry(key.toString(), value))
      : const {};
}
