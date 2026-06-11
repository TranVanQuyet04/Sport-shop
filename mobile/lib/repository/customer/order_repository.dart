import '../../model/customer/order_model.dart';

abstract interface class OrderRepository {
  Future<List<OrderModel>> getMyOrders();

  Future<List<OrderModel>> getAllOrders();

  Future<OrderModel?> getMyOrderById(String orderId);

  Future<OrderModel?> getAdminOrderById(String orderId);

  Future<OrderModel> updateStatus({
    required String orderId,
    required String status,
    bool asAdminOrShipper,
  });
}
