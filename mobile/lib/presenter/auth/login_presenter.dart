import 'package:flutter/foundation.dart';

import '../../app/sportshop_router.dart';
import '../../core/auth/role_mapper.dart';
import '../../model/auth/login_form_model.dart';
import '../../repository/auth/auth_repository.dart';

class LoginPresenter extends ChangeNotifier {
  LoginPresenter({required this.authRepository});

  final AuthRepository authRepository;

  LoginFormModel _form = const LoginFormModel();
  bool _isLoading = false;
  bool _hasSubmitted = false;
  String? _errorMessage;

  LoginFormModel get form => _form;
  bool get isLoading => _isLoading;
  bool get hasSubmitted => _hasSubmitted;
  String? get errorMessage => _errorMessage;

  String? get emailError {
    if (!_hasSubmitted || _form.email.trim().isEmpty || _form.hasValidEmail) {
      return null;
    }
    return 'Email chưa đúng định dạng.';
  }

  String? get passwordError {
    if (!_hasSubmitted || _form.hasValidPassword) {
      return null;
    }
    return 'Vui lòng nhập mật khẩu.';
  }

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

  Future<String?> submit() async {
    _hasSubmitted = true;
    if (!_form.canSubmit) {
      _errorMessage = 'Vui lòng nhập email và mật khẩu.';
      notifyListeners();
      return null;
    }
    if (!_form.hasValidEmail) {
      _errorMessage = 'Email chưa đúng định dạng.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await authRepository.login(
        email: _form.email.trim(),
        password: _form.password,
      );
      _isLoading = false;
      notifyListeners();
      return _routeForRole(session.role);
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  String _routeForRole(String? role) {
    final normalizedRole = RoleMapper.normalize(role);
    return switch (normalizedRole) {
      'ADMIN' => AppRoutes.adminDashboard,
      'SHIPPER' => AppRoutes.deliveryHome,
      'MEMBER' => AppRoutes.customerHome,
      _ => AppRoutes.customerHome,
    };
  }
}
