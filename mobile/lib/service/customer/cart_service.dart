import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../model/customer/cart_model.dart';

abstract interface class CartService {
  Future<CartModel> getMyCart();

  Future<CartModel> addToCart({
    required String variantId,
    required int quantity,
  });

  Future<CartModel> updateQuantity({
    required String itemId,
    required int quantity,
  });

  Future<CartModel> removeItem(String itemId);

  Future<void> clearCart();
}

class CartApiService implements CartService {
  const CartApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<CartModel> getMyCart() async {
    final json = await _apiClient.getJson(ApiEndpoints.cart);
    return CartModel.fromJson(json);
  }

  @override
  Future<CartModel> addToCart({
    required String variantId,
    required int quantity,
  }) async {
    final json = await _apiClient.postJson(
      '${ApiEndpoints.cart}/add',
      data: {
        'variantId': int.tryParse(variantId) ?? variantId,
        'quantity': quantity,
      },
    );
    return CartModel.fromJson(json);
  }

  @override
  Future<CartModel> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    final json = await _apiClient.putJson(
      '${ApiEndpoints.cart}/items/$itemId',
      queryParameters: {'quantity': quantity},
    );
    return CartModel.fromJson(json);
  }

  @override
  Future<CartModel> removeItem(String itemId) async {
    final json = await _apiClient.deleteJson(
      '${ApiEndpoints.cart}/items/$itemId',
    );
    return CartModel.fromJson(json);
  }

  @override
  Future<void> clearCart() async {
    await _apiClient.deleteJson('${ApiEndpoints.cart}/clear');
  }
}
