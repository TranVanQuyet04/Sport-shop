import 'package:flutter/foundation.dart';

import '../../model/customer/address_model.dart';
import '../../model/customer/cart_model.dart';
import '../../model/customer/order_model.dart';
import '../../repository/customer/cart_repository.dart';
import '../../repository/customer/checkout_repository.dart';

class CheckoutController extends ChangeNotifier {
  CheckoutController({
    required this.cartRepository,
    required this.checkoutRepository,
  });

  final CartRepository cartRepository;
  final CheckoutRepository checkoutRepository;

  CartModel cart = CartModel.empty();
  List<AddressModel> addresses = const [];
  AddressModel? selectedAddress;
  String paymentMethod = 'COD';
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  OrderModel? createdOrder;

  Future<void> loadCheckout() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<Object>([
        cartRepository.getMyCart(),
        checkoutRepository.getAddresses(),
      ]);
      cart = results[0] as CartModel;
      addresses = results[1] as List<AddressModel>;
      selectedAddress = _pickDefaultAddress(addresses);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectPaymentMethod(String value) {
    paymentMethod = value;
    notifyListeners();
  }

  Future<bool> submitOrder(String note) async {
    final address = selectedAddress;
    if (address == null) {
      errorMessage = 'Vui lòng thêm địa chỉ giao hàng trước khi đặt hàng.';
      notifyListeners();
      return false;
    }
    if (cart.isEmpty) {
      errorMessage = 'Giỏ hàng đang trống, không thể đặt hàng.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      createdOrder = await checkoutRepository.checkout(
        addressId: address.id,
        paymentMethod: paymentMethod,
        note: note,
      );
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  AddressModel? _pickDefaultAddress(List<AddressModel> addresses) {
    if (addresses.isEmpty) {
      return null;
    }
    return addresses.firstWhere(
      (address) => address.isDefault,
      orElse: () => addresses.first,
    );
  }
}
