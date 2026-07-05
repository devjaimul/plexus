import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<String> login({
    required String username,
    required String password,
  }) async {
    final data = await _client.post(
      '/auth/login',
      body: {'username': username, 'password': password},
    );

    final token = data is Map<String, dynamic>
        ? data['token'] as String?
        : null;
    if (token == null || token.isEmpty) {
      throw const UnexpectedException('Login response contained no token');
    }
    return token;
  }

  Future<UserModel> fetchUser(int id) async {
    final data = await _client.get('/users/$id');
    if (data is! Map<String, dynamic>) {
      throw const ApiException(404, 'User not found');
    }
    return UserModel.fromJson(data);
  }
}
