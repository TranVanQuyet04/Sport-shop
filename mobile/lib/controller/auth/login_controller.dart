import 'package:flutter/foundation.dart';

import '../../app/sportshop_router.dart';
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

  Future<String?> submit() async {
    if (!_form.canSubmit) {
      _errorMessage = 'Vui lòng nhập email và mật khẩu.';
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
    final normalizedRole = role?.toUpperCase().replaceFirst('ROLE_', '').trim();
    return switch (normalizedRole) {
      'ADMIN' => AppRoutes.adminDashboard,
      'SHOP_STAFF' => AppRoutes.shopStaffHome,
      'DELIVERY_STAFF' => AppRoutes.deliveryHome,
      'CUSTOMER' => AppRoutes.customerHome,
      _ => AppRoutes.customerHome,
    };
  }
}
