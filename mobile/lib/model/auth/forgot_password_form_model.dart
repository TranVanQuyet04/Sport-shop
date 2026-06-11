class ForgotPasswordFormModel {
  const ForgotPasswordFormModel({this.email = ''});

  final String email;

  bool get canSubmit => email.trim().isNotEmpty;

  ForgotPasswordFormModel copyWith({String? email}) {
    return ForgotPasswordFormModel(email: email ?? this.email);
  }
}
