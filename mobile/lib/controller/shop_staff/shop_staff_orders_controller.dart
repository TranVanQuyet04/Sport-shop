import 'package:flutter/foundation.dart';

import '../../core/mock/customer_demo_data.dart';
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
      if (orders.isEmpty) {
        orders = _demoOrders;
      }
    } catch (error) {
      orders = _demoOrders;
      errorMessage = 'Đang hiển thị đơn hàng mẫu vì chưa kết nối được backend.';
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
      orders = orders
          .map(
            (order) => order.id == orderId ? _copyOrder(order, status) : order,
          )
          .toList();
      errorMessage = 'Đã cập nhật trạng thái đơn hàng ở chế độ demo.';
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  List<OrderModel> get _demoOrders {
    final base = CustomerDemoData.orders;
    return [
      _copyOrder(base.first, OrderStatus.pending, id: 'AV-8843'),
      _copyOrder(base.first, OrderStatus.pending, id: 'AV-8845'),
      _copyOrder(base.last, OrderStatus.confirmed, id: 'AV-8842'),
      _copyOrder(base.last, OrderStatus.packing, id: 'AV-8844'),
    ];
  }

  OrderModel _copyOrder(OrderModel order, OrderStatus status, {String? id}) {
    return OrderModel(
      id: id ?? order.id,
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
