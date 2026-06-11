import 'package:flutter/foundation.dart';

import '../../model/auth/reset_password_form_model.dart';
import '../../repository/auth/auth_repository.dart';

class ResetPasswordController extends ChangeNotifier {
  ResetPasswordController({required this.authRepository});

  final AuthRepository authRepository;

  ResetPasswordFormModel _form = const ResetPasswordFormModel();
  bool _isLoading = false;
  String? _errorMessage;

  ResetPasswordFormModel get form => _form;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void changeToken(String value) {
    _form = _form.copyWith(token: value);
    _errorMessage = null;
    notifyListeners();
  }

  void changeNewPassword(String value) {
    _form = _form.copyWith(newPassword: value);
    _errorMessage = null;
    notifyListeners();
  }

  void changeConfirmPassword(String value) {
    _form = _form.copyWith(confirmPassword: value);
    _errorMessage = null;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _form = _form.copyWith(isNewPasswordVisible: !_form.isNewPasswordVisible);
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _form = _form.copyWith(isConfirmPasswordVisible: !_form.isConfirmPasswordVisible);
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!_form.canSubmit) {
      _errorMessage = 'Vui lòng nhập token và mật khẩu mới.';
      notifyListeners();
      return false;
    }
    if (!_form.passwordsMatch) {
      _errorMessage = 'Mật khẩu xác nhận không khớp.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authRepository.resetPassword(
        token: _form.token.trim(),
        newPassword: _form.newPassword,
        confirmPassword: _form.confirmPassword,
      );
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
