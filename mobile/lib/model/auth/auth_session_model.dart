class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    this.refreshToken,
    this.email,
    this.role,
  });

  final String accessToken;
  final String? refreshToken;
  final String? email;
  final String? role;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final source = result is Map ? Map<String, dynamic>.from(result) : json;

    return AuthSessionModel(
      accessToken: (source['accessToken'] ?? source['token'] ?? '').toString(),
      refreshToken: source['refreshToken']?.toString(),
      email: source['email']?.toString(),
      role: source['role']?.toString() ?? source['roleName']?.toString(),
    );
  }
}
