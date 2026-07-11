enum OrderStatus {
  pending,
  confirmed,
  packing,
  shipped,
  delivered,
  completed,
  cancelled;

  static OrderStatus fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'PENDING' => OrderStatus.pending,
      'PAID' => OrderStatus.confirmed,
      'CONFIRMED' => OrderStatus.confirmed,
      'PACKING' => OrderStatus.packing,
      'SHIPPING' => OrderStatus.shipped,
      'SHIPPED' => OrderStatus.shipped,
      'DELIVERED' => OrderStatus.delivered,
      'COMPLETED' => OrderStatus.completed,
      'CANCELLED' => OrderStatus.cancelled,
      _ => OrderStatus.pending,
    };
  }

  String get apiValue {
    return switch (this) {
      OrderStatus.pending => 'PENDING',
      OrderStatus.confirmed => 'CONFIRMED',
      OrderStatus.packing => 'PACKING',
      OrderStatus.shipped => 'SHIPPED',
      OrderStatus.delivered => 'DELIVERED',
      OrderStatus.completed => 'COMPLETED',
      OrderStatus.cancelled => 'CANCELLED',
    };
  }
}
