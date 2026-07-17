import 'package:flutter/foundation.dart';

abstract final class ApiEndpoints {
  static const String _envBaseUrl = String.fromEnvironment('SPORTSHOP_API_URL');
  static const String _envAuthUrl = String.fromEnvironment(
    'SPORTSHOP_AUTH_API_URL',
  );
  static const String _envCatalogUrl = String.fromEnvironment(
    'SPORTSHOP_CATALOG_API_URL',
  );
  static const String _envOrderUrl = String.fromEnvironment(
    'SPORTSHOP_ORDER_API_URL',
  );
  static const String _envChatUrl = String.fromEnvironment(
    'SPORTSHOP_CHAT_API_URL',
  );

  static String get _host => kIsWeb ? 'localhost' : '10.0.2.2';

  /// A configured gateway takes precedence. Without a gateway, each request is
  /// sent directly to the microservice that owns its endpoint.
  static String get baseUrl => _gatewayOr(authBaseUrl);

  static String get authBaseUrl => _serviceUrl(_envAuthUrl, 8081);
  static String get catalogBaseUrl => _serviceUrl(_envCatalogUrl, 8082);
  static String get orderBaseUrl => _serviceUrl(_envOrderUrl, 8083);
  static String get chatBaseUrl => _serviceUrl(_envChatUrl, 8084);

  static String resolveBaseUrl(String path) {
    if (_envBaseUrl.isNotEmpty) {
      return _normalize(_envBaseUrl);
    }

    if (_isAuthPath(path)) {
      return authBaseUrl;
    }
    if (_isCatalogPath(path)) {
      return catalogBaseUrl;
    }
    if (path == '/chat' || path.startsWith('/chat/')) {
      return chatBaseUrl;
    }
    return orderBaseUrl;
  }

  static bool _isAuthPath(String path) {
    return path == '/auth' ||
        path.startsWith('/auth/') ||
        path.startsWith('/user/profile') ||
        path.startsWith('/user/addresses') ||
        path.startsWith('/admin/users') ||
        path.startsWith('/admin/roles') ||
        path.startsWith('/admin/settings');
  }

  static bool _isCatalogPath(String path) {
    return path == '/products' ||
        path.startsWith('/products/') ||
        path == '/brands' ||
        path.startsWith('/brands/') ||
        path == '/collections' ||
        path.startsWith('/collections/') ||
        path == '/navigation' ||
        path.startsWith('/navigation/') ||
        path.startsWith('/admin/products') ||
        path.startsWith('/admin/categories') ||
        path.startsWith('/admin/sports');
  }

  static String _serviceUrl(String configuredUrl, int port) => _gatewayOr(
    configuredUrl.isNotEmpty ? configuredUrl : 'http://$_host:$port/api',
  );

  static String _gatewayOr(String fallback) =>
      _normalize(_envBaseUrl.isNotEmpty ? _envBaseUrl : fallback);

  static String _normalize(String url) => url.replaceFirst(RegExp(r'/+$'), '');

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-pass';

  static bool isPublicAuthPath(String path) =>
      path == login ||
      path == register ||
      path == refreshToken ||
      path == forgotPassword ||
      path == resetPassword;

  static const String products = '/products';
  static const String productCategories = '/products/categories';
  static const String productBrands = '/products/brands';
  static const String cart = '/cart';
  static const String myOrders = '/orders/my-orders';
  static const String orders = '/orders';
  static const String adminOrders = '/orders/admin';
  static const String addresses = '/user/addresses';
  static const String profile = '/user/profile/me';
  static const String navigationMain = '/navigation/main';
  static const String collections = '/collections';
  static const String adminCollections = '/collections/admin';
  static const String adminSports = '/admin/sports';
  static const String payment = '/payment';
}
