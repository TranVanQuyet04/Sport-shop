import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  const TokenStorage({
    this.secureStorage = const FlutterSecureStorage(),
  });

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage secureStorage;

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await secureStorage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<String?> readAccessToken() {
    return secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> clear() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
  }
}
