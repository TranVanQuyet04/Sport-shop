import 'package:flutter/foundation.dart';

import '../../core/mock/customer_demo_data.dart';
import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../../repository/customer/order_repository.dart';

class DeliveryOrdersController extends ChangeNotifier {
  DeliveryOrdersController({required this.orderRepository});

  final OrderRepository orderRepository;

  List<OrderModel> orders = const [];
  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;

  List<OrderModel> get assignedOrders {
    return orders.where((order) {
      final status = OrderStatus.fromApi(order.status);
      return status == OrderStatus.shipped || status == OrderStatus.completed;
    }).toList();
  }

  Future<void> loadOrders() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      orders = await orderRepository.getAllOrders();
      if (orders.isEmpty) {
        orders = CustomerDemoData.orders;
      }
    } catch (error) {
      orders = CustomerDemoData.orders;
      errorMessage =
          'Đang hiển thị đơn giao hàng mẫu vì chưa kết nối được backend.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeDelivery(String orderId) async {
    return _updateStatus(orderId, OrderStatus.completed);
  }

  Future<bool> markFailed(String orderId) async {
    return _updateStatus(orderId, OrderStatus.cancelled);
  }

  Future<bool> _updateStatus(String orderId, OrderStatus status) async {
    isUpdating = true;
    errorMessage = null;
    notifyListeners();

    try {
      await orderRepository.updateStatus(
        orderId: orderId,
        status: status.apiValue,
        asAdminOrShipper: true,
      );
      orders = await orderRepository.getAllOrders();
      return true;
    } catch (error) {
      orders = orders
          .map(
            (order) => order.id == orderId ? _copyOrder(order, status) : order,
          )
          .toList();
      errorMessage = 'Đã cập nhật giao hàng ở chế độ demo.';
      return true;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  OrderModel _copyOrder(OrderModel order, OrderStatus status) {
    return OrderModel(
      id: order.id,
      status: status.apiValue,
      totalAmount: order.totalAmount,
      paymentMethod: order.paymentMethod,
      recipientName: order.recipientName,
      phoneNumber: order.phoneNumber,
      shippingAddress: order.shippingAddress,
      note: order.note,
      orderDate: order.orderDate,
      items: order.items,
    );
  }
}
