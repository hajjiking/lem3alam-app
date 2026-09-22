import 'package:dio/dio.dart';

import '../../../core/networking/api_client.dart';
import '../domain/client_kyc.dart';

class ClientKycApi {
  ClientKycApi(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> load() =>
      _client.getJson<Map<String, dynamic>>('kyc/documents');

  Future<Map<String, dynamic>> submit(KycSubmission submission) =>
      _client.postJson<Map<String, dynamic>>(
        'kyc/documents',
        data: FormData.fromMap({
          'type': submission.type.apiValue,
          'document': MultipartFile.fromBytes(
            submission.bytes,
            filename: submission.fileName,
          ),
        }),
      );
}
