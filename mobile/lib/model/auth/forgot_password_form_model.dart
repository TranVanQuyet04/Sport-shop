class ForgotPasswordFormModel {
  const ForgotPasswordFormModel({this.email = ''});

  final String email;

  bool get canSubmit => email.trim().isNotEmpty;
  bool get hasValidEmail =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());

  ForgotPasswordFormModel copyWith({String? email}) {
    return ForgotPasswordFormModel(email: email ?? this.email);
  }
}
