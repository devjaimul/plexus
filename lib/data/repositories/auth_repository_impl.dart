import '../../core/utils/jwt.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/token_storage.dart';
import '../datasources/remote/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthApi api, required TokenStorage tokenStorage})
    : _api = api,
      _tokenStorage = tokenStorage;

  final AuthApi _api;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSession> restoreSession() async {
    final token = await _tokenStorage.readToken();
    final username = await _tokenStorage.readUsername();
    if (token == null || username == null) {
      return const AuthSession.signedOut();
    }
    return AuthSession.signedIn(
      username: username,
      profile: await _fetchProfile(token),
    );
  }

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final token = await _api.login(username: username, password: password);
    await _tokenStorage.save(token: token, username: username);
    return AuthSession.signedIn(
      username: username,
      profile: await _fetchProfile(token),
    );
  }

  @override
  Future<void> logout() => _tokenStorage.clear();

  // best effort only, sign-in never blocks on the profile
  Future<User?> _fetchProfile(String token) async {
    final userId = jwtUserId(token);
    if (userId == null) return null;

    try {
      final user = await _api.fetchUser(userId);
      return user.toEntity();
    } on Exception {
      return null;
    }
  }
}
