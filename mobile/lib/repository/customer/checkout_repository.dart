import '../../model/customer/address_model.dart';
import '../../model/customer/order_model.dart';

abstract interface class CheckoutRepository {
  Future<List<AddressModel>> getAddresses();

  Future<OrderModel> checkout({
    required String addressId,
    required String paymentMethod,
    required String note,
  });
}
