import 'package:flutter_test/flutter_test.dart';
import 'package:sportswear_shop_mobile/core/network/api_endpoints.dart';

void main() {
  group('ApiEndpoints microservice routing', () {
    test('routes identity endpoints to auth service', () {
      expect(ApiEndpoints.resolveBaseUrl('/auth/login'), contains(':8081/api'));
      expect(
        ApiEndpoints.resolveBaseUrl('/user/addresses'),
        contains(':8081/api'),
      );
      expect(
        ApiEndpoints.resolveBaseUrl('/admin/settings'),
        contains(':8081/api'),
      );
    });

    test('routes catalog endpoints to product catalog service', () {
      expect(ApiEndpoints.resolveBaseUrl('/products'), contains(':8082/api'));
      expect(
        ApiEndpoints.resolveBaseUrl('/admin/products/1'),
        contains(':8082/api'),
      );
      expect(
        ApiEndpoints.resolveBaseUrl('/navigation/main'),
        contains(':8082/api'),
      );
    });

    test('routes fulfillment endpoints to order service', () {
      expect(
        ApiEndpoints.resolveBaseUrl('/orders/my-orders'),
        contains(':8083/api'),
      );
      expect(ApiEndpoints.resolveBaseUrl('/cart'), contains(':8083/api'));
      expect(
        ApiEndpoints.resolveBaseUrl('/admin/reports/dashboard'),
        contains(':8083/api'),
      );
    });

    test('routes chat endpoints to support chat service', () {
      expect(
        ApiEndpoints.resolveBaseUrl('/chat/rooms/me'),
        contains(':8084/api'),
      );
    });
  });

  group('ApiEndpoints public authentication paths', () {
    test('marks unauthenticated auth operations as public', () {
      expect(ApiEndpoints.isPublicAuthPath(ApiEndpoints.login), isTrue);
      expect(ApiEndpoints.isPublicAuthPath(ApiEndpoints.register), isTrue);
      expect(ApiEndpoints.isPublicAuthPath(ApiEndpoints.forgotPassword), isTrue);
      expect(ApiEndpoints.isPublicAuthPath(ApiEndpoints.logout), isFalse);
      expect(ApiEndpoints.isPublicAuthPath(ApiEndpoints.profile), isFalse);
    });
  });
}
