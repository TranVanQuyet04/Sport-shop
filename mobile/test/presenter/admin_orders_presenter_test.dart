import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sportswear_shop_mobile/model/customer/order_model.dart';
import 'package:sportswear_shop_mobile/presenter/admin/admin_orders_presenter.dart';
import 'package:sportswear_shop_mobile/repository/customer/order_repository.dart';

void main() {
  group('AdminOrdersPresenter lifecycle', () {
    test('loadOrders ignores async result after dispose', () async {
      final repository = _FakeOrderRepository();
      final presenter = AdminOrdersPresenter(orderRepository: repository);
      var notifications = 0;
      presenter.addListener(() => notifications++);

      final pendingLoad = presenter.loadOrders();
      expect(notifications, 1);
      expect(presenter.isLoading, isTrue);

      presenter.dispose();
      repository.completeAllOrders([_order(id: '453')]);
      await pendingLoad;

      expect(notifications, 1);
    });

    test('updateOrderStatus ignores refresh result after dispose', () async {
      final repository = _FakeOrderRepository();
      final presenter = AdminOrdersPresenter(orderRepository: repository);
      var notifications = 0;
      presenter.addListener(() => notifications++);

      final pendingUpdate = presenter.updateOrderStatus('453', 'SHIPPED');
      expect(notifications, 1);
      expect(presenter.isUpdating, isTrue);

      repository.completeUpdate(_order(id: '453', status: 'SHIPPED'));
      await Future<void>.delayed(Duration.zero);
      presenter.dispose();
      repository.completeAllOrders([_order(id: '453', status: 'SHIPPED')]);
      await pendingUpdate;

      expect(notifications, 1);
    });
  });
}

class _FakeOrderRepository implements OrderRepository {
  Completer<List<OrderModel>>? _allOrdersCompleter;
  Completer<OrderModel>? _updateCompleter;

  void completeAllOrders(List<OrderModel> orders) {
    _allOrdersCompleter?.complete(orders);
  }

  void completeUpdate(OrderModel order) {
    _updateCompleter?.complete(order);
  }

  @override
  Future<List<OrderModel>> getAllOrders() {
    _allOrdersCompleter = Completer<List<OrderModel>>();
    return _allOrdersCompleter!.future;
  }

  @override
  Future<List<OrderModel>> getMyOrders() async => const [];

  @override
  Future<OrderModel> getAdminOrderById(String orderId) async {
    return _order(id: orderId);
  }

  @override
  Future<OrderModel> getMyOrderById(String orderId) async {
    return _order(id: orderId);
  }

  @override
  Future<OrderModel> updateStatus({
    required String orderId,
    required String status,
    bool asAdminOrShipper = false,
  }) {
    _updateCompleter = Completer<OrderModel>();
    return _updateCompleter!.future;
  }
}

OrderModel _order({required String id, String status = 'PENDING'}) {
  return OrderModel(
    id: id,
    status: status,
    deliveryStatus: '',
    totalAmount: 692000,
    paymentMethod: 'COD',
    recipientName: 'tquyet1',
    phoneNumber: '0838972333',
    shippingAddress: 'hcm, hcm, hcm',
    note: '',
    orderDate: DateTime(2026, 7, 10),
    items: const [
      OrderItemModel(
        id: '1',
        variantId: 'PXAP12',
        productName: 'giày x',
        size: '42',
        color: 'black',
        price: 346000,
        quantity: 2,
        subTotal: 692000,
        variantImage: '',
      ),
    ],
  );
}
