import '../../../core/networking/api_client.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return _client.postJson<Map<String, dynamic>>(
      'login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String role,
    required String city,
  }) async {
    return _client.postJson<Map<String, dynamic>>(
      'register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,
        'role': role,
        'city': city,
      },
    );
  }

  Future<Map<String, dynamic>> logout() {
    return _client.postJson<Map<String, dynamic>>('logout');
  }

  Future<Map<String, dynamic>> me() {
    return _client.getJson<Map<String, dynamic>>('user');
  }
}
