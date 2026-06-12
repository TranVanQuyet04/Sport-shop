import 'package:flutter/foundation.dart';

import '../../core/mock/customer_demo_data.dart';
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
      cart = CustomerDemoData.cart;
      errorMessage = 'Đang hiển thị giỏ hàng mẫu vì chưa kết nối được backend.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> increase(CartItemModel item) async {
    final nextQuantity = item.quantity + 1;
    await _updateQuantity(item.id, nextQuantity);
  }

  Future<void> decrease(CartItemModel item) async {
    if (item.quantity <= 1) {
      return remove(item.id);
    }
    await _updateQuantity(item.id, item.quantity - 1);
  }

  Future<void> remove(String itemId) async {
    final previousCart = cart;
    cart = _removeLocal(itemId);
    notifyListeners();
    await _runMutation(
      () => cartRepository.removeItem(itemId),
      fallbackCart: cart,
      previousCart: previousCart,
    );
  }

  Future<void> clear() async {
    await _runMutation(() async {
      await cartRepository.clearCart();
      return CartModel.empty();
    });
  }

  Future<void> _updateQuantity(String itemId, int quantity) async {
    final previousCart = cart;
    cart = _updateLocalQuantity(itemId, quantity);
    notifyListeners();
    await _runMutation(
      () => cartRepository.updateQuantity(itemId: itemId, quantity: quantity),
      fallbackCart: cart,
      previousCart: previousCart,
    );
  }

  Future<void> _runMutation(
    Future<CartModel> Function() action, {
    CartModel? fallbackCart,
    CartModel? previousCart,
  }) async {
    isUpdating = true;
    errorMessage = null;
    notifyListeners();

    try {
      cart = await action();
    } catch (error) {
      cart = fallbackCart ?? previousCart ?? cart;
      errorMessage = 'Đã cập nhật giỏ hàng ở chế độ demo.';
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  CartModel _updateLocalQuantity(String itemId, int quantity) {
    final items = cart.items
        .map(
          (item) => item.id == itemId
              ? _copyItem(
                  item,
                  quantity: quantity,
                  subTotal: item.price * quantity,
                )
              : item,
        )
        .toList();
    return _copyCart(items);
  }

  CartModel _removeLocal(String itemId) {
    return _copyCart(cart.items.where((item) => item.id != itemId).toList());
  }

  CartModel _copyCart(List<CartItemModel> items) {
    return CartModel(
      id: cart.id,
      totalPrice: items.fold<int>(0, (total, item) => total + item.subTotal),
      totalItems: items.fold<int>(0, (total, item) => total + item.quantity),
      items: items,
    );
  }

  CartItemModel _copyItem(
    CartItemModel item, {
    required int quantity,
    required int subTotal,
  }) {
    return CartItemModel(
      id: item.id,
      variantId: item.variantId,
      productName: item.productName,
      size: item.size,
      color: item.color,
      price: item.price,
      quantity: quantity,
      subTotal: subTotal,
      imageUrl: item.imageUrl,
      maxStock: item.maxStock,
    );
  }
}
