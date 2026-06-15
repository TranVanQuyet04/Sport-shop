import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  const TokenStorage({
    this.secureStorage = const FlutterSecureStorage(),
  });

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _roleKey = 'role';
  static const String _emailKey = 'email';

  final FlutterSecureStorage secureStorage;

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? role,
    String? email,
  }) async {
    await secureStorage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
    if (role != null && role.isNotEmpty) {
      await secureStorage.write(key: _roleKey, value: role);
    }
    if (email != null && email.isNotEmpty) {
      await secureStorage.write(key: _emailKey, value: email);
    }
  }

  Future<String?> readAccessToken() {
    return secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return secureStorage.read(key: _refreshTokenKey);
  }

  Future<String?> readRole() {
    return secureStorage.read(key: _roleKey);
  }

  Future<String?> readEmail() {
    return secureStorage.read(key: _emailKey);
  }

  Future<void> clear() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
    await secureStorage.delete(key: _roleKey);
    await secureStorage.delete(key: _emailKey);
  }
}
