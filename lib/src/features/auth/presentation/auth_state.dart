import '../domain/user.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
  });

  final AuthStatus status;
  final User? user;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }

  static const unknown = AuthState(status: AuthStatus.unknown);
  static const unauthenticated = AuthState(status: AuthStatus.unauthenticated);
}

