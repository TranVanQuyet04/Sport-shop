import 'package:flutter/foundation.dart';

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
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
