abstract final class ApiEndpoints {
  static const String baseUrl = 'http://10.0.2.2:8083/api';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';

  static const String products = '/products';
  static const String cart = '/cart';
  static const String myOrders = '/orders/my-orders';
}
