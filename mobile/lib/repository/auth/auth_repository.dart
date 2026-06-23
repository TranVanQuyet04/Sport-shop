import '../../model/auth/auth_session_model.dart';

abstract interface class AuthRepository {
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

  Future<void> forgotPassword({
    required String email,
  });

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });

  Future<AuthSessionModel> refreshToken();

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> logout();
}
