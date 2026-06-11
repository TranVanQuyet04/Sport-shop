import 'package:flutter/foundation.dart';

import '../../model/customer/order_model.dart';
import '../../repository/customer/order_repository.dart';

class AdminOrdersController extends ChangeNotifier {
  AdminOrdersController({required this.orderRepository});

  final OrderRepository orderRepository;

  List<OrderModel> orders = const [];
  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;

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
      orders = await orderRepository.getAllOrders();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }
}
