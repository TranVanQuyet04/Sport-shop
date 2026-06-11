import '../../model/customer/cart_model.dart';

abstract interface class CartRepository {
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
