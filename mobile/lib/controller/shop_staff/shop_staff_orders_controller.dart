import 'package:flutter/foundation.dart';

import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../../repository/customer/order_repository.dart';

class ShopStaffOrdersController extends ChangeNotifier {
  ShopStaffOrdersController({required this.orderRepository});

  final OrderRepository orderRepository;

  List<OrderModel> orders = const [];
  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;

  List<OrderModel> get pendingOrders {
    return orders
        .where(
          (order) => OrderStatus.fromApi(order.status) == OrderStatus.pending,
        )
        .toList();
  }

  List<OrderModel> get confirmedOrders {
    return orders
        .where(
          (order) => OrderStatus.fromApi(order.status) == OrderStatus.confirmed,
        )
        .toList();
  }

  Future<void> loadOrders() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      orders = await orderRepository.getAllOrders();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
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
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }
}
