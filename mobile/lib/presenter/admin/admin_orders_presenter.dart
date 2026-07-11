import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../../repository/customer/order_repository.dart';

class AdminOrdersPresenter extends ChangeNotifier {
  AdminOrdersPresenter({required this.orderRepository});

  final OrderRepository orderRepository;

  List<OrderModel> _orders = const [];
  OrderStatus? selectedStatus;
  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;
  Timer? _refreshTimer;
  bool _disposed = false;

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
    if (_disposed) return;
    selectedStatus = status;
    _safeNotifyListeners();
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 8)}) {
    if (_disposed) return;
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) {
      if (!_disposed && !isLoading && !isUpdating) {
        loadOrders(showLoading: false);
      }
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> loadOrders({bool showLoading = true}) async {
    if (_disposed) return;
    if (showLoading) {
      isLoading = true;
    }
    errorMessage = null;
    if (showLoading) {
      _safeNotifyListeners();
    }

    try {
      final loadedOrders = await orderRepository.getAllOrders();
      if (_disposed) return;
      _orders = loadedOrders;
    } catch (error) {
      if (_disposed) return;
      _orders = const [];
      errorMessage = error.toString();
    } finally {
      if (!_disposed) {
        if (showLoading) {
          isLoading = false;
        }
        _safeNotifyListeners();
      }
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    if (_disposed) return;
    isUpdating = true;
    errorMessage = null;
    _safeNotifyListeners();

    try {
      await orderRepository.updateStatus(
        orderId: orderId,
        status: status,
        asAdminOrShipper: true,
      );
      final loadedOrders = await orderRepository.getAllOrders();
      if (_disposed) return;
      _orders = loadedOrders;
    } catch (error) {
      if (_disposed) return;
      errorMessage = error.toString();
    } finally {
      if (!_disposed) {
        isUpdating = false;
        _safeNotifyListeners();
      }
    }
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    stopAutoRefresh();
    super.dispose();
  }
}
