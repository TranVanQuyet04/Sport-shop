class LoginFormModel {
  const LoginFormModel({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
  });

  final String email;
  final String password;
  final bool isPasswordVisible;

  bool get canSubmit => email.trim().isNotEmpty && password.isNotEmpty;
  bool get hasValidEmail =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  bool get hasValidPassword => password.isNotEmpty;

  LoginFormModel copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
  }) {
    return LoginFormModel(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}
