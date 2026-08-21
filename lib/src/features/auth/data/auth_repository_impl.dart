import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/dio_provider.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';
import 'auth_api.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    api: AuthApi(ref.watch(apiClientProvider)),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.api, required this.tokenStorage});

  final AuthApi api;
  final TokenStorage tokenStorage;

  @override
  Future<User> fetchMe() async {
    final json = await api.me();
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return User.fromJson(data);
  }

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    final json = await api.login(email: email, password: password);
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    final token = (data['token'] ?? '').toString();
    final user = User.fromJson((data['user'] as Map<String, dynamic>?) ?? const {});

    if (token.isEmpty) {
      throw const FormatException('Login response missing token');
    }

    await tokenStorage.write(token);
    return AuthResult(user: user, token: token);
  }

  @override
  Future<void> logout() async {
    try {
      await api.logout();
    } finally {
      await tokenStorage.clear();
    }
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String role,
    required String city,
  }) async {
    final json = await api.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      phone: phone,
      role: role,
      city: city,
    );
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    final token = (data['token'] ?? '').toString();
    final user = User.fromJson((data['user'] as Map<String, dynamic>?) ?? const {});

    if (token.isEmpty) {
      throw const FormatException('Register response missing token');
    }

    await tokenStorage.write(token);
    return AuthResult(user: user, token: token);
  }
}
