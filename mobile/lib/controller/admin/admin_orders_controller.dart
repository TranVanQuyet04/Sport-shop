import 'package:flutter/foundation.dart';

import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../../repository/customer/order_repository.dart';

class AdminOrdersController extends ChangeNotifier {
  AdminOrdersController({required this.orderRepository});

  final OrderRepository orderRepository;

  List<OrderModel> _orders = const [];
  OrderStatus? selectedStatus;
  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;

  List<OrderModel> get allOrders => _orders;

  List<OrderModel> get orders {
    if (selectedStatus == null) {
      return _orders;
    }
    return _orders
        .where((order) => OrderStatus.fromApi(order.status) == selectedStatus)
        .toList();
  }

  int get totalOrders => _orders.length;

  void selectStatus(OrderStatus? status) {
    selectedStatus = status;
    notifyListeners();
  }

  Future<void> loadOrders() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _orders = await orderRepository.getAllOrders();
    } catch (error) {
      _orders = const [];
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    isUpdating = true;
    errorMessage = null;
    notifyListeners();

    try {
      await orderRepository.updateStatus(
        orderId: orderId,
        status: status,
        asAdminOrShipper: true,
      );
      _orders = await orderRepository.getAllOrders();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }
}
