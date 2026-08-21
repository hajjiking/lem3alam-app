import 'user.dart';

class AuthResult {
  const AuthResult({required this.user, required this.token});

  final User user;
  final String token;
}

abstract class AuthRepository {
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String role,
    required String city,
  });

  Future<void> logout();
  Future<User> fetchMe();
}

