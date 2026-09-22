import '../../../core/networking/api_client.dart';
import '../domain/client_profile.dart';

class ClientProfileApi {
  ClientProfileApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getProfile() =>
      _client.getJson<Map<String, dynamic>>('profile');

  Future<Map<String, dynamic>> updateProfile(ClientProfileUpdate update) =>
      _client.putJson<Map<String, dynamic>>(
        'profile',
        data: update.toJson(),
      );
}
