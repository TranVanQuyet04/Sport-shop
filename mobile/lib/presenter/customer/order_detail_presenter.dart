import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../model/customer/order_model.dart';
import '../../repository/customer/order_repository.dart';

class OrderDetailPresenter extends ChangeNotifier {
  OrderDetailPresenter({
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
  Timer? _refreshTimer;
  bool _disposed = false;

  void startAutoRefresh({Duration interval = const Duration(seconds: 8)}) {
    if (_disposed) return;
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) {
      if (!_disposed && !isLoading && !isUpdating) {
        loadOrder(showLoading: false);
      }
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> loadOrder({bool showLoading = true}) async {
    if (_disposed) return;
    if (showLoading) {
      isLoading = true;
    }
    errorMessage = null;
    if (showLoading) {
      _safeNotifyListeners();
    }

    try {
      final loadedOrder = useAdminOrders
          ? await orderRepository.getAdminOrderById(orderId)
          : await orderRepository.getMyOrderById(orderId);
      if (_disposed) return;
      order = loadedOrder;
    } catch (error) {
      if (_disposed) return;
      order = null;
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

  Future<bool> cancelOrder() {
    return _updateStatus('CANCELLED');
  }

  Future<bool> completeOrder() {
    return _updateStatus('COMPLETED');
  }

  Future<bool> _updateStatus(String status) async {
    if (_disposed) return false;
    isUpdating = true;
    errorMessage = null;
    _safeNotifyListeners();

    try {
      final updatedOrder = await orderRepository.updateStatus(
        orderId: orderId,
        status: status,
      );
      if (_disposed) return false;
      order = updatedOrder;
      return true;
    } catch (error) {
      if (_disposed) return false;
      errorMessage = error.toString();
      return false;
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
