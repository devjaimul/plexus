import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/auth_api.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import 'app_providers.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    api: ref.watch(authApiProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final authSessionProvider = AsyncNotifierProvider<AuthNotifier, AuthSession>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthSession> {
  @override
  Future<AuthSession> build() async {
    try {
      return await ref.read(authRepositoryProvider).restoreSession();
    } on Exception {
      // broken keychain read = just show login
      return const AuthSession.signedOut();
    }
  }

  /// Throws on failure, state only changes on success.
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final session = await ref
        .read(authRepositoryProvider)
        .login(username: username, password: password);
    state = AsyncData(session);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthSession.signedOut());
  }
}
