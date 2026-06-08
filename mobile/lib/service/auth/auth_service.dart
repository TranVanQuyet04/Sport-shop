import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../model/auth/auth_session_model.dart';

abstract interface class AuthService {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });
}

class AuthApiService implements AuthService {
  const AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final json = await _apiClient.postJson(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    return AuthSessionModel.fromJson(json);
  }
}
