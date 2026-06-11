import 'package:flutter/foundation.dart';

import '../../model/auth/register_form_model.dart';
import '../../repository/auth/auth_repository.dart';

class RegisterController extends ChangeNotifier {
  RegisterController({required this.authRepository});

  final AuthRepository authRepository;

  RegisterFormModel _form = const RegisterFormModel();
  bool _isLoading = false;
  String? _errorMessage;

  RegisterFormModel get form => _form;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void changeFullName(String value) {
    _form = _form.copyWith(fullName: value);
    _errorMessage = null;
    notifyListeners();
  }

  void changeEmail(String value) {
    _form = _form.copyWith(email: value);
    _errorMessage = null;
    notifyListeners();
  }

  void changePhoneNumber(String value) {
    _form = _form.copyWith(phoneNumber: value);
    _errorMessage = null;
    notifyListeners();
  }

  void changePassword(String value) {
    _form = _form.copyWith(password: value);
    _errorMessage = null;
    notifyListeners();
  }

  void changeConfirmPassword(String value) {
    _form = _form.copyWith(confirmPassword: value);
    _errorMessage = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _form = _form.copyWith(isPasswordVisible: !_form.isPasswordVisible);
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _form = _form.copyWith(isConfirmPasswordVisible: !_form.isConfirmPasswordVisible);
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!_form.canSubmit) {
      _errorMessage = 'Vui lòng nhập đầy đủ thông tin.';
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
      await authRepository.register(
        fullName: _form.fullName.trim(),
        email: _form.email.trim(),
        phoneNumber: _form.phoneNumber.trim(),
        password: _form.password,
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
