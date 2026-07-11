import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
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
    final json = await _apiClient.getJson('${ApiEndpoints.myOrders}/$orderId');
    return OrderModel.fromJson(json);
  }

  @override
  Future<OrderModel> getAdminOrderById(String orderId) async {
    final json = await _apiClient.getJson(
      '${ApiEndpoints.adminOrders}/$orderId',
    );
    return OrderModel.fromJson(json);
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
    final orders = rawItems
        .whereType<Map>()
        .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    orders.sort(_compareNewestFirst);
    return orders;
  }

  int _compareNewestFirst(OrderModel left, OrderModel right) {
    final leftDate = left.orderDate;
    final rightDate = right.orderDate;
    if (leftDate != null && rightDate != null) {
      final dateCompare = rightDate.compareTo(leftDate);
      if (dateCompare != 0) {
        return dateCompare;
      }
    } else if (leftDate != null) {
      return -1;
    } else if (rightDate != null) {
      return 1;
    }

    final leftId = int.tryParse(left.id.replaceAll('#', '')) ?? 0;
    final rightId = int.tryParse(right.id.replaceAll('#', '')) ?? 0;
    return rightId.compareTo(leftId);
  }
}
