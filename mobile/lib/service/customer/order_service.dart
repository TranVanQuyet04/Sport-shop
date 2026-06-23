import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../model/customer/order_model.dart';

abstract interface class OrderService {
  Future<List<OrderModel>> getMyOrders();

  Future<List<OrderModel>> getAllOrders();

  Future<OrderModel> getMyOrderById(String orderId);

  Future<OrderModel> getAdminOrderById(String orderId);

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
    final json = await _apiClient.getJson(ApiEndpoints.myOrders);
    return _parseOrders(json);
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    final json = await _apiClient.getJson(ApiEndpoints.adminOrders);
    return _parseOrders(json);
  }

  @override
  Future<OrderModel> getMyOrderById(String orderId) async {
    return _findOrderById(await getMyOrders(), orderId);
  }

  @override
  Future<OrderModel> getAdminOrderById(String orderId) async {
    return _findOrderById(await getAllOrders(), orderId);
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

  OrderModel _findOrderById(List<OrderModel> orders, String orderId) {
    final cleanId = orderId.replaceAll('#', '').trim();
    for (final order in orders) {
      if (order.id.replaceAll('#', '').trim() == cleanId) {
        return order;
      }
    }
    throw const ApiException('Không tìm thấy đơn hàng.', statusCode: 404);
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
