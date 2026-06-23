import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../model/customer/address_model.dart';
import '../../model/customer/order_model.dart';

abstract interface class CheckoutService {
  Future<List<AddressModel>> getAddresses();

  Future<OrderModel> checkout({
    required String addressId,
    required String paymentMethod,
    required String note,
  });
}

class CheckoutApiService implements CheckoutService {
  const CheckoutApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<AddressModel>> getAddresses() async {
    final json = await _apiClient.getJson(ApiEndpoints.addresses);
    final rawItems = json['result'] ?? json['data'] ?? json;
    if (rawItems is! List) {
      return const [];
    }
    return rawItems
        .whereType<Map>()
        .map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<OrderModel> checkout({
    required String addressId,
    required String paymentMethod,
    required String note,
  }) async {
    final json = await _apiClient.postJson(
      '/orders/checkout',
      data: {
        'addressId': int.tryParse(addressId) ?? addressId,
        'paymentMethod': paymentMethod,
        'note': note,
      },
    );
    return OrderModel.fromJson(json);
  }
}
