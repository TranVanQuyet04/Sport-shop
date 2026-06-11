import '../../model/customer/address_model.dart';
import '../../model/customer/order_model.dart';
import '../../service/customer/checkout_service.dart';
import 'checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  const CheckoutRepositoryImpl(this._checkoutService);

  final CheckoutService _checkoutService;

  @override
  Future<List<AddressModel>> getAddresses() {
    return _checkoutService.getAddresses();
  }

  @override
  Future<OrderModel> checkout({
    required String addressId,
    required String paymentMethod,
    required String note,
  }) {
    return _checkoutService.checkout(
      addressId: addressId,
      paymentMethod: paymentMethod,
      note: note,
    );
  }
}
