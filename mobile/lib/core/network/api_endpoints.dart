import 'package:flutter/foundation.dart';

abstract final class ApiEndpoints {
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8083/api';
  static const String _browserBaseUrl = 'http://localhost:8083/api';

  static String get baseUrl =>
      kIsWeb ? _browserBaseUrl : _androidEmulatorBaseUrl;

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-pass';

  static const String products = '/products';
  static const String productBrands = '/products/brands';
  static const String cart = '/cart';
  static const String myOrders = '/orders';
  static const String adminOrders = '/orders/admin';
  static const String addresses = '/user/addresses';
  static const String profile = '/user/profile/me';
  static const String navigationMain = '/navigation/main';
  static const String collections = '/collections';
  static const String adminCollections = '/collections/admin';
  static const String adminSports = '/admin/sports';
  static const String payment = '/payment';
}
