import 'package:flutter/foundation.dart';

import '../../model/customer/order_model.dart';
import '../../repository/customer/order_repository.dart';

class OrderDetailController extends ChangeNotifier {
  OrderDetailController({
    required this.orderRepository,
    required this.orderId,
    this.useAdminOrders = false,
  });

  final OrderRepository orderRepository;
  final String orderId;
  final bool useAdminOrders;

  OrderModel? order;
  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;

  Future<void> loadOrder() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      order = useAdminOrders
          ? await orderRepository.getAdminOrderById(orderId)
          : await orderRepository.getMyOrderById(orderId);
      if (order == null) {
        errorMessage = 'Không tìm thấy đơn hàng #$orderId.';
      }
    } catch (error) {
      order = null;
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder() {
    return _updateStatus('CANCELLED');
  }

  Future<bool> completeOrder() {
    return _updateStatus('COMPLETED');
  }

  Future<bool> _updateStatus(String status) async {
    isUpdating = true;
    errorMessage = null;
    notifyListeners();

    try {
      order = await orderRepository.updateStatus(
        orderId: orderId,
        status: status,
      );
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
