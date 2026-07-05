import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/app_constants.dart';

abstract interface class TokenStorage {
  Future<String?> readToken();

  Future<String?> readUsername();

  Future<void> save({required String token, required String username});

  Future<void> clear();
}

/// Keychain on iOS, encrypted shared preferences on Android.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() => _storage.read(key: AppConstants.authTokenKey);

  @override
  Future<String?> readUsername() =>
      _storage.read(key: AppConstants.authUsernameKey);

  @override
  Future<void> save({required String token, required String username}) =>
      Future.wait([
        _storage.write(key: AppConstants.authTokenKey, value: token),
        _storage.write(key: AppConstants.authUsernameKey, value: username),
      ]);

  @override
  Future<void> clear() => Future.wait([
    _storage.delete(key: AppConstants.authTokenKey),
    _storage.delete(key: AppConstants.authUsernameKey),
  ]);
}
