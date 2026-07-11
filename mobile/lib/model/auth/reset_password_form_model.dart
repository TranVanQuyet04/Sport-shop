class ResetPasswordFormModel {
  const ResetPasswordFormModel({
    this.token = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.isNewPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  final String token;
  final String newPassword;
  final String confirmPassword;
  final bool isNewPasswordVisible;
  final bool isConfirmPasswordVisible;

  bool get canSubmit =>
      token.trim().isNotEmpty &&
      newPassword.isNotEmpty &&
      confirmPassword.isNotEmpty;

  bool get hasValidToken => token.trim().isNotEmpty;
  bool get hasValidPassword =>
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(newPassword);
  bool get passwordsMatch => newPassword == confirmPassword;

  ResetPasswordFormModel copyWith({
    String? token,
    String? newPassword,
    String? confirmPassword,
    bool? isNewPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return ResetPasswordFormModel(
      token: token ?? this.token,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isNewPasswordVisible: isNewPasswordVisible ?? this.isNewPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }
}
