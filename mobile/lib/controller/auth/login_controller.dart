import 'package:flutter/foundation.dart';

import '../../model/auth/login_form_model.dart';
import '../../repository/auth/auth_repository.dart';

class LoginController extends ChangeNotifier {
  LoginController({required this.authRepository});

  final AuthRepository authRepository;

  LoginFormModel _form = const LoginFormModel();
  bool _isLoading = false;
  String? _errorMessage;

  LoginFormModel get form => _form;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void changeEmail(String value) {
    _form = _form.copyWith(email: value);
    _errorMessage = null;
    notifyListeners();
  }

  void changePassword(String value) {
    _form = _form.copyWith(password: value);
    _errorMessage = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _form = _form.copyWith(isPasswordVisible: !_form.isPasswordVisible);
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!_form.canSubmit) {
      _errorMessage = 'Vui lòng nhập email và mật khẩu.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authRepository.login(
        email: _form.email.trim(),
        password: _form.password,
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
