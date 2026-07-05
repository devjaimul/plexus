import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> restoreSession();

  Future<AuthSession> login({
    required String username,
    required String password,
  });

  Future<void> logout();
}
