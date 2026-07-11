import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../model/auth/auth_session_model.dart';

abstract interface class AuthService {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  });

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });

  Future<AuthSessionModel> refreshToken(String refreshToken);

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> logout();
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
      data: {'email': email, 'password': password},
    );
    return AuthSessionModel.fromJson(json);
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    await _apiClient.postJson(
      ApiEndpoints.register,
      data: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _apiClient.postJson(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _apiClient.postJson(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  @override
  Future<AuthSessionModel> refreshToken(String refreshToken) async {
    final json = await _apiClient.postJson(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );
    return AuthSessionModel.fromJson(json);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _apiClient.putJson(
      ApiEndpoints.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  @override
  Future<void> logout() async {
    await _apiClient.postJson(ApiEndpoints.logout);
  }
}
