import 'package:flutter/foundation.dart';

import '../../model/auth/forgot_password_form_model.dart';
import '../../repository/auth/auth_repository.dart';

class ForgotPasswordPresenter extends ChangeNotifier {
  ForgotPasswordPresenter({required this.authRepository});

  final AuthRepository authRepository;

  ForgotPasswordFormModel _form = const ForgotPasswordFormModel();
  bool _isLoading = false;
  bool _hasSubmitted = false;
  String? _errorMessage;

  ForgotPasswordFormModel get form => _form;
  bool get isLoading => _isLoading;
  bool get hasSubmitted => _hasSubmitted;
  String? get errorMessage => _errorMessage;
  String? get emailError =>
      !_hasSubmitted || _form.email.trim().isEmpty || _form.hasValidEmail
      ? null
      : 'Email chưa đúng định dạng.';

  void changeEmail(String value) {
    _form = _form.copyWith(email: value);
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submit() async {
    _hasSubmitted = true;
    if (!_form.canSubmit) {
      _errorMessage = 'Vui lòng nhập email.';
      notifyListeners();
      return false;
    }
    if (!_form.hasValidEmail) {
      _errorMessage = 'Email chưa đúng định dạng.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authRepository.forgotPassword(email: _form.email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }
}
