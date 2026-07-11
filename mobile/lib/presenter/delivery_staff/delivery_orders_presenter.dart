import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../model/common/order_status.dart';
import '../../model/customer/order_model.dart';
import '../../repository/customer/order_repository.dart';
import '../../repository/delivery/delivery_operations_repository.dart';

class DeliveryOrdersPresenter extends ChangeNotifier {
  DeliveryOrdersPresenter({
    required this.orderRepository,
    required this.deliveryOperationsRepository,
  });

  final OrderRepository orderRepository;
  final DeliveryOperationsRepository deliveryOperationsRepository;

  List<OrderModel> orders = const [];
  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;
  Timer? _refreshTimer;
  bool _disposed = false;

  List<OrderModel> get assignedOrders {
    return orders.where((order) {
      final status = OrderStatus.fromApi(order.status);
      return status == OrderStatus.shipped ||
          status == OrderStatus.delivered ||
          status == OrderStatus.completed ||
          status == OrderStatus.cancelled;
    }).toList();
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
      final assignments = await deliveryOperationsRepository.getAssignments();
      if (_disposed) return;
      if (assignments.isEmpty) {
        final loadedOrders = await orderRepository.getAllOrders();
        if (_disposed) return;
        orders = loadedOrders;
      } else {
        final loadedOrders = <OrderModel>[];
        for (final assignment in assignments) {
          if (_disposed) return;
          try {
            loadedOrders.add(
              await orderRepository.getAdminOrderById(assignment.orderId),
            );
          } catch (_) {
            // Keep loading the rest of the assigned orders.
          }
        }
        if (_disposed) return;
        orders = loadedOrders;
      }
    } catch (error) {
      if (_disposed) return;
      try {
        final loadedOrders = await orderRepository.getAllOrders();
        if (_disposed) return;
        orders = loadedOrders;
        errorMessage =
            'Không tải được danh sách phân công, đang hiển thị đơn giao từ danh sách đơn hàng.';
      } catch (_) {
        if (_disposed) return;
        orders = const [];
        errorMessage = error.toString();
      }
    } finally {
      if (!_disposed) {
        if (showLoading) {
          isLoading = false;
        }
        _safeNotifyListeners();
      }
    }
  }

  Future<bool> completeDelivery(String orderId) async {
    return _updateStatus(orderId, OrderStatus.delivered);
  }

  Future<bool> startDelivery(String orderId) async {
    return _updateStatus(orderId, OrderStatus.shipped);
  }

  Future<bool> markFailed(String orderId) async {
    if (_disposed) return false;
    isUpdating = true;
    errorMessage = null;
    _safeNotifyListeners();

    try {
      await deliveryOperationsRepository.createReport(
        orderId: orderId,
        status: 'FAILED',
        reason: 'Giao hàng thất bại',
        note: 'Nhân viên giao hàng báo không giao được đơn.',
      );
      if (_disposed) return false;
      await loadOrders();
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

  Future<bool> _updateStatus(String orderId, OrderStatus status) async {
    return _updateStatusValue(orderId, status.apiValue);
  }

  Future<bool> _updateStatusValue(String orderId, String status) async {
    if (_disposed) return false;
    isUpdating = true;
    errorMessage = null;
    _safeNotifyListeners();

    try {
      await orderRepository.updateStatus(
        orderId: orderId,
        status: status,
        asAdminOrShipper: true,
      );
      if (_disposed) return false;
      await loadOrders(showLoading: false);
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
