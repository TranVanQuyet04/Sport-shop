import 'package:flutter/foundation.dart';

import '../../core/mock/customer_demo_data.dart';
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
      if (_orders.isEmpty) {
        _orders = _adminDemoOrders;
      }
    } catch (error) {
      _orders = _adminDemoOrders;
      errorMessage = 'Đang hiển thị đơn hàng mẫu vì chưa kết nối được backend.';
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
      if (_orders.isEmpty) {
        _orders = _adminDemoOrders;
      }
    } catch (error) {
      _orders = _orders
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

  OrderModel _copyOrder(OrderModel order, String status) {
    return OrderModel(
      id: order.id,
      status: status,
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

  List<OrderModel> get _adminDemoOrders {
    final base = CustomerDemoData.orders;
    return [
      _copyOrder(
        base.first,
        OrderStatus.pending.apiValue,
      ).copyWithId('SP24061301'),
      _copyOrder(
        base.last,
        OrderStatus.confirmed.apiValue,
      ).copyWithId('SP24061302'),
      _copyOrder(
        base.first,
        OrderStatus.packing.apiValue,
      ).copyWithId('SP24061303'),
      _copyOrder(
        base.last,
        OrderStatus.shipped.apiValue,
      ).copyWithId('SP24061204'),
      _copyOrder(
        base.first,
        OrderStatus.completed.apiValue,
      ).copyWithId('SP24061105'),
    ];
  }
}

extension on OrderModel {
  OrderModel copyWithId(String id) {
    return OrderModel(
      id: id,
      status: status,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      recipientName: recipientName,
      phoneNumber: phoneNumber,
      shippingAddress: shippingAddress,
      note: note,
      orderDate: orderDate,
      items: items,
    );
  }
}
