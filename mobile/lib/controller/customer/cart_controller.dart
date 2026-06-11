import 'package:flutter/foundation.dart';

import '../../model/customer/cart_model.dart';
import '../../repository/customer/cart_repository.dart';

class CartController extends ChangeNotifier {
  CartController({required this.cartRepository});

  final CartRepository cartRepository;

  CartModel cart = CartModel.empty();
  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;

  Future<void> loadCart() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      cart = await cartRepository.getMyCart();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> increase(CartItemModel item) {
    final nextQuantity = item.quantity + 1;
    return _updateQuantity(item.id, nextQuantity);
  }

  Future<void> decrease(CartItemModel item) {
    if (item.quantity <= 1) {
      return remove(item.id);
    }
    return _updateQuantity(item.id, item.quantity - 1);
  }

  Future<void> remove(String itemId) async {
    await _runMutation(() => cartRepository.removeItem(itemId));
  }

  Future<void> clear() async {
    await _runMutation(() async {
      await cartRepository.clearCart();
      return CartModel.empty();
    });
  }

  Future<void> _updateQuantity(String itemId, int quantity) async {
    await _runMutation(
      () => cartRepository.updateQuantity(itemId: itemId, quantity: quantity),
    );
  }

  Future<void> _runMutation(Future<CartModel> Function() action) async {
    isUpdating = true;
    errorMessage = null;
    notifyListeners();

    try {
      cart = await action();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }
}
