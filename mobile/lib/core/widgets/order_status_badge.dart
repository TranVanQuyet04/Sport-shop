import 'package:flutter/material.dart';

import '../../model/common/delivery_status.dart';
import '../../model/common/order_status.dart';
import 'status_badge.dart';

extension OrderStatusPresentation on OrderStatus {
  String get label {
    return switch (this) {
      OrderStatus.pending => 'Chờ xác nhận',
      OrderStatus.confirmed => 'Đã xác nhận',
      OrderStatus.packing => 'Đang đóng gói',
      OrderStatus.shipped => 'Đã bàn giao',
      OrderStatus.delivered => 'Shipper đã giao',
      OrderStatus.completed => 'Hoàn thành',
      OrderStatus.cancelled => 'Đã hủy',
    };
  }

  StatusTone get tone {
    return switch (this) {
      OrderStatus.pending => StatusTone.warning,
      OrderStatus.confirmed => StatusTone.info,
      OrderStatus.packing => StatusTone.info,
      OrderStatus.shipped => StatusTone.info,
      OrderStatus.delivered => StatusTone.success,
      OrderStatus.completed => StatusTone.success,
      OrderStatus.cancelled => StatusTone.error,
    };
  }
}

extension DeliveryStatusPresentation on DeliveryStatus {
  String get label {
    return switch (this) {
      DeliveryStatus.waitingPickup => 'Chờ lấy hàng',
      DeliveryStatus.pickedUp => 'Đã lấy hàng',
      DeliveryStatus.inTransit => 'Đang vận chuyển',
      DeliveryStatus.outForDelivery => 'Đang giao',
      DeliveryStatus.delivered => 'Đã giao',
      DeliveryStatus.failed => 'Giao thất bại',
      DeliveryStatus.returned => 'Hoàn trả',
    };
  }

  StatusTone get tone {
    return switch (this) {
      DeliveryStatus.waitingPickup => StatusTone.warning,
      DeliveryStatus.pickedUp => StatusTone.info,
      DeliveryStatus.inTransit => StatusTone.info,
      DeliveryStatus.outForDelivery => StatusTone.info,
      DeliveryStatus.delivered => StatusTone.success,
      DeliveryStatus.failed => StatusTone.error,
      DeliveryStatus.returned => StatusTone.warning,
    };
  }
}

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(label: status.label, tone: status.tone);
  }
}

class DeliveryStatusBadge extends StatelessWidget {
  const DeliveryStatusBadge({super.key, required this.status});

  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(label: status.label, tone: status.tone);
  }
}
