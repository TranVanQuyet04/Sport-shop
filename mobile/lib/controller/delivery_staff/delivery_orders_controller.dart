import 'package:flutter/foundation.dart';

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
    } catch (error) {
      orders = const [];
      errorMessage = error.toString();
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
      errorMessage = error.toString();
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }
}
