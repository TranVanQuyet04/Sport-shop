import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../model/auth/auth_session_model.dart';
import '../../service/auth/auth_service.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.authService,
    required this.tokenStorage,
    required this.apiClient,
  });

  final AuthService authService;
  final TokenStorage tokenStorage;
  final ApiClient apiClient;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final session = await authService.login(email: email, password: password);
    await tokenStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      role: session.role,
      email: session.email,
    );
    apiClient.setBearerToken(session.accessToken);
    return session;
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) {
    return authService.register(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  @override
  Future<void> forgotPassword({
    required String email,
  }) {
    return authService.forgotPassword(email: email);
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) {
    return authService.resetPassword(
      token: token,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clear();
    apiClient.setBearerToken(null);
  }
}
