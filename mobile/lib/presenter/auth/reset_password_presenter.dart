import 'package:flutter/foundation.dart';

import '../../model/auth/reset_password_form_model.dart';
import '../../repository/auth/auth_repository.dart';

class ResetPasswordPresenter extends ChangeNotifier {
  ResetPasswordPresenter({required this.authRepository});

  final AuthRepository authRepository;

  ResetPasswordFormModel _form = const ResetPasswordFormModel();
  bool _isLoading = false;
  bool _hasSubmitted = false;
  String? _errorMessage;

  ResetPasswordFormModel get form => _form;
  bool get isLoading => _isLoading;
  bool get hasSubmitted => _hasSubmitted;
  String? get errorMessage => _errorMessage;
  String? get tokenError =>
      !_hasSubmitted || _form.hasValidToken ? null : 'Vui lòng nhập token.';
  String? get passwordError =>
      !_hasSubmitted || _form.newPassword.isEmpty || _form.hasValidPassword
      ? null
      : 'Mật khẩu cần ít nhất 8 ký tự, gồm chữ và số.';
  String? get confirmPasswordError =>
      !_hasSubmitted || _form.confirmPassword.isEmpty || _form.passwordsMatch
      ? null
      : 'Mật khẩu xác nhận không khớp.';

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
    _form = _form.copyWith(
      isConfirmPasswordVisible: !_form.isConfirmPasswordVisible,
    );
    notifyListeners();
  }

  Future<bool> submit() async {
    _hasSubmitted = true;
    if (!_form.canSubmit) {
      _errorMessage = 'Vui lòng nhập token và mật khẩu mới.';
      notifyListeners();
      return false;
    }
    if (!_form.hasValidPassword) {
      _errorMessage = 'Vui lòng kiểm tra lại mật khẩu mới.';
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
