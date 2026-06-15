import 'package:flutter/foundation.dart';

abstract final class ApiEndpoints {
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8080/api';
  static const String _browserBaseUrl = 'http://localhost:8080/api';

  static String get baseUrl =>
      kIsWeb ? _browserBaseUrl : _androidEmulatorBaseUrl;

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  static const String products = '/products';
  static const String cart = '/cart';
  static const String myOrders = '/orders/my-orders';
}
