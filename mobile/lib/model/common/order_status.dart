enum OrderStatus {
  pending,
  confirmed,
  packing,
  shipped,
  completed,
  cancelled;

  static OrderStatus fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'PENDING' => OrderStatus.pending,
      'CONFIRMED' => OrderStatus.confirmed,
      'PACKING' => OrderStatus.packing,
      'SHIPPED' => OrderStatus.shipped,
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
      OrderStatus.completed => 'COMPLETED',
      OrderStatus.cancelled => 'CANCELLED',
    };
  }
}
