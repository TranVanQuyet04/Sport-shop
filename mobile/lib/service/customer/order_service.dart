import '../../core/network/api_client.dart';
import '../../model/customer/order_model.dart';

abstract interface class OrderService {
  Future<List<OrderModel>> getMyOrders();

  Future<List<OrderModel>> getAllOrders();

  Future<OrderModel> updateStatus({
    required String orderId,
    required String status,
    bool asAdminOrShipper,
  });
}

class OrderApiService implements OrderService {
  const OrderApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<OrderModel>> getMyOrders() async {
    final json = await _apiClient.getJson('/orders');
    return _parseOrders(json);
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    final json = await _apiClient.getJson('/orders/admin');
    return _parseOrders(json);
  }

  @override
  Future<OrderModel> updateStatus({
    required String orderId,
    required String status,
    bool asAdminOrShipper = false,
  }) async {
    final endpoint = asAdminOrShipper
        ? '/orders/$orderId/status'
        : '/orders/$orderId/orderStatus';
    final json = await _apiClient.patchJson(
      endpoint,
      queryParameters: {'status': status},
    );
    return OrderModel.fromJson(json);
  }

  List<OrderModel> _parseOrders(Map<String, dynamic> json) {
    final rawItems = json['result'] ?? json['data'] ?? json;
    if (rawItems is! List) {
      return const [];
    }
    return rawItems
        .whereType<Map>()
        .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
