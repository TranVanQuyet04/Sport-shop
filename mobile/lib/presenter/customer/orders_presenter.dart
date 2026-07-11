import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../model/customer/order_model.dart';
import '../../repository/customer/order_repository.dart';

class OrdersPresenter extends ChangeNotifier {
  OrdersPresenter({required this.orderRepository});

  final OrderRepository orderRepository;

  List<OrderModel> orders = const [];
  bool isLoading = false;
  String? errorMessage;
  Timer? _refreshTimer;
  bool _disposed = false;

  void startAutoRefresh({Duration interval = const Duration(seconds: 8)}) {
    if (_disposed) return;
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) {
      if (!_disposed && !isLoading) {
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
      final loadedOrders = await orderRepository.getMyOrders();
      if (_disposed) return;
      orders = loadedOrders;
    } catch (error) {
      if (_disposed) return;
      orders = const [];
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
