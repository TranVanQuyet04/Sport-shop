import '../../model/customer/order_model.dart';
import '../../service/customer/order_service.dart';
import 'order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl(this._orderService);

  final OrderService _orderService;

  @override
  Future<List<OrderModel>> getMyOrders() {
    return _orderService.getMyOrders();
  }

  @override
  Future<List<OrderModel>> getAllOrders() {
    return _orderService.getAllOrders();
  }

  @override
  Future<OrderModel> getMyOrderById(String orderId) async {
    return _orderService.getMyOrderById(orderId.replaceAll('#', ''));
  }

  @override
  Future<OrderModel> getAdminOrderById(String orderId) async {
    return _orderService.getAdminOrderById(orderId.replaceAll('#', ''));
  }

  @override
  Future<OrderModel> updateStatus({
    required String orderId,
    required String status,
    bool asAdminOrShipper = false,
  }) {
    return _orderService.updateStatus(
      orderId: orderId.replaceAll('#', ''),
      status: status,
      asAdminOrShipper: asAdminOrShipper,
    );
  }
}
