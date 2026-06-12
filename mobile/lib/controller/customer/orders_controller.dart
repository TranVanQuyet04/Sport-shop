import 'package:flutter/foundation.dart';

import '../../core/mock/customer_demo_data.dart';
import '../../model/customer/order_model.dart';
import '../../repository/customer/order_repository.dart';

class OrdersController extends ChangeNotifier {
  OrdersController({required this.orderRepository});

  final OrderRepository orderRepository;

  List<OrderModel> orders = const [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadOrders() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      orders = await orderRepository.getMyOrders();
      if (orders.isEmpty) {
        orders = CustomerDemoData.orders;
      }
    } catch (error) {
      orders = CustomerDemoData.orders;
      errorMessage = 'Đang hiển thị đơn hàng mẫu vì chưa kết nối được backend.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
