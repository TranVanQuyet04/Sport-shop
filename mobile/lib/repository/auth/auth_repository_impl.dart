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
    );
    apiClient.setBearerToken(session.accessToken);
    return session;
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clear();
    apiClient.setBearerToken(null);
  }
}
