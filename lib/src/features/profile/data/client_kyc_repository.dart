import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/client_kyc.dart';
import 'client_kyc_api.dart';

final clientKycRepositoryProvider = Provider<ClientKycRepository>((ref) {
  return ClientKycRepository(
    api: ClientKycApi(ref.watch(apiClientProvider)),
    readAuth: () => ref.read(authControllerProvider),
    expireSession: () =>
        ref.read(authControllerProvider.notifier).expireSession(),
  );
});

class ClientKycRepository {
  static const maxDocumentBytes = 5 * 1024 * 1024;
  static const allowedExtensions = {'jpg', 'jpeg', 'png', 'pdf'};

  ClientKycRepository({
    required this.api,
    required this.readAuth,
    required this.expireSession,
  });

  final ClientKycApi api;
  final AuthState Function() readAuth;
  final Future<void> Function() expireSession;

  Future<KycOverview> load() async {
    final response = await _authenticated(api.load);
    return KycOverview.fromJson(_map(response['data']));
  }

  Future<KycOverview> submit(KycSubmission submission) async {
    final extension = submission.fileName.split('.').last.toLowerCase();
    if (submission.bytes.isEmpty ||
        submission.bytes.length > maxDocumentBytes ||
        !allowedExtensions.contains(extension)) {
      throw const ApiException(message: 'err_invalid_kyc_document');
    }
    await _authenticated(() => api.submit(submission));
    return load();
  }

  Future<Map<String, dynamic>> _authenticated(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    final requested = readAuth().user;
    if (readAuth().status != AuthStatus.authenticated ||
        requested?.isClient != true) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    try {
      final response = await request();
      final current = readAuth().user;
      if (current?.id != requested!.id || current?.isClient != true) {
        throw const ApiException(statusCode: 403, message: 'err_forbidden');
      }
      return response;
    } on ApiException catch (error) {
      if (error.statusCode == 401 && readAuth().user?.id == requested?.id) {
        await expireSession();
      }
      rethrow;
    }
  }

  static Map<String, dynamic> _map(dynamic value) => value is Map
      ? value.map((key, value) => MapEntry(key.toString(), value))
      : const {};
}
