import '../../model/customer/cart_model.dart';
import '../../service/customer/cart_service.dart';
import 'cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._cartService);

  final CartService _cartService;

  @override
  Future<CartModel> getMyCart() {
    return _cartService.getMyCart();
  }

  @override
  Future<CartModel> addToCart({
    required String variantId,
    required int quantity,
  }) {
    return _cartService.addToCart(variantId: variantId, quantity: quantity);
  }

  @override
  Future<CartModel> updateQuantity({
    required String itemId,
    required int quantity,
  }) {
    return _cartService.updateQuantity(itemId: itemId, quantity: quantity);
  }

  @override
  Future<CartModel> removeItem(String itemId) {
    return _cartService.removeItem(itemId);
  }

  @override
  Future<void> clearCart() {
    return _cartService.clearCart();
  }
}
