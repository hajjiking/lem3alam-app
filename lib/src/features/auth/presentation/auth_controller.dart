import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/dio_provider.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import 'auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  var _bootstrapped = false;

  AuthRepository get authRepository => ref.read(authRepositoryProvider);
  TokenStorage get tokenStorage => ref.read(tokenStorageProvider);

  @override
  AuthState build() {
    if (!_bootstrapped) {
      _bootstrapped = true;
      Future.microtask(bootstrap);
    }
    return AuthState.unknown;
  }

  Future<void> bootstrap() async {
    final token = await tokenStorage.read();
    if (token == null || token.isEmpty) {
      state = AuthState.unauthenticated;
      return;
    }

    try {
      final me = await authRepository.fetchMe();
      state = AuthState(status: AuthStatus.authenticated, user: me);
    } catch (_) {
      // #region debug-point A:bootstrap-auth-failed
      (() { try { final client = HttpClient(); client.postUrl(Uri.parse('http://127.0.0.1:7778/event')).then((req) { req.headers.contentType = ContentType.json; req.write(jsonEncode({'sessionId': 'tasker-tasks-crash', 'runId': 'pre-fix', 'hypothesisId': 'A', 'location': 'auth_controller.dart:27', 'msg': '[DEBUG] bootstrap failed and clearing session', 'data': {'statusBefore': state.status.name}, 'ts': DateTime.now().millisecondsSinceEpoch})); return req.close(); }).then((res) => res.drain<void>()).whenComplete(client.close).catchError((_) {}); } catch (_) {} })();
      // #endregion
      await tokenStorage.clear();
      state = AuthState.unauthenticated;
    }
  }

  Future<void> login({required String email, required String password}) async {
    final result = await authRepository.login(email: email, password: password);
    state = AuthState(status: AuthStatus.authenticated, user: result.user);
  }

  Future<void> expireSession() async {
    // #region debug-point A:expire-session
    (() { try { final client = HttpClient(); client.postUrl(Uri.parse('http://127.0.0.1:7778/event')).then((req) { req.headers.contentType = ContentType.json; req.write(jsonEncode({'sessionId': 'tasker-tasks-crash', 'runId': 'pre-fix', 'hypothesisId': 'A', 'location': 'auth_controller.dart:37', 'msg': '[DEBUG] expireSession invoked', 'data': {'statusBefore': state.status.name, 'role': state.user?.role}, 'ts': DateTime.now().millisecondsSinceEpoch})); return req.close(); }).then((res) => res.drain<void>()).whenComplete(client.close).catchError((_) {}); } catch (_) {} })();
    // #endregion
    await tokenStorage.clear();
    state = AuthState.unauthenticated;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String role,
    required String city,
  }) async {
    final result = await authRepository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      phone: phone,
      role: role,
      city: city,
    );
    state = AuthState(status: AuthStatus.authenticated, user: result.user);
  }

  Future<void> logout() async {
    await authRepository.logout();
    state = AuthState.unauthenticated;
  }
}
