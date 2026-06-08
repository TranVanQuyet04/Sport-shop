enum DeliveryStatus {
  waitingPickup,
  pickedUp,
  inTransit,
  outForDelivery,
  delivered,
  failed,
  returned;

  static DeliveryStatus fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'WAITING_PICKUP' => DeliveryStatus.waitingPickup,
      'PICKED_UP' => DeliveryStatus.pickedUp,
      'IN_TRANSIT' => DeliveryStatus.inTransit,
      'OUT_FOR_DELIVERY' => DeliveryStatus.outForDelivery,
      'DELIVERED' => DeliveryStatus.delivered,
      'FAILED' => DeliveryStatus.failed,
      'RETURNED' => DeliveryStatus.returned,
      _ => DeliveryStatus.waitingPickup,
    };
  }

  String get apiValue {
    return switch (this) {
      DeliveryStatus.waitingPickup => 'WAITING_PICKUP',
      DeliveryStatus.pickedUp => 'PICKED_UP',
      DeliveryStatus.inTransit => 'IN_TRANSIT',
      DeliveryStatus.outForDelivery => 'OUT_FOR_DELIVERY',
      DeliveryStatus.delivered => 'DELIVERED',
      DeliveryStatus.failed => 'FAILED',
      DeliveryStatus.returned => 'RETURNED',
    };
  }
}
