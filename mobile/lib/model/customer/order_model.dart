class OrderModel {
  const OrderModel({
    required this.id,
    required this.status,
    required this.deliveryStatus,
    required this.totalAmount,
    required this.paymentMethod,
    required this.recipientName,
    required this.phoneNumber,
    required this.shippingAddress,
    required this.note,
    required this.orderDate,
    required this.items,
  });

  final String id;
  final String status;
  final String deliveryStatus;
  final int totalAmount;
  final String paymentMethod;
  final String recipientName;
  final String phoneNumber;
  final String shippingAddress;
  final String note;
  final DateTime? orderDate;
  final List<OrderItemModel> items;

  String get firstProductName {
    if (items.isEmpty) {
      return '';
    }
    return items.first.productName;
  }

  int get totalItems {
    return items.fold<int>(0, (total, item) => total + item.quantity);
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final source = json['result'] is Map
        ? Map<String, dynamic>.from(json['result'] as Map)
        : json;
    final rawItems = source['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    OrderItemModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <OrderItemModel>[];

    return OrderModel(
      id: (source['id'] ?? '').toString(),
      status: (source['status'] ?? '').toString(),
      deliveryStatus: (source['deliveryStatus'] ?? '').toString(),
      totalAmount: _toInt(source['totalAmount']),
      paymentMethod: (source['paymentMethod'] ?? '').toString(),
      recipientName: (source['recipientName'] ?? '').toString(),
      phoneNumber: (source['phoneNumber'] ?? '').toString(),
      shippingAddress: (source['shippingAddress'] ?? '').toString(),
      note: (source['note'] ?? '').toString(),
      orderDate: DateTime.tryParse((source['orderDate'] ?? '').toString()),
      items: items,
    );
  }
}

class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.variantId,
    required this.productName,
    required this.size,
    required this.color,
    required this.price,
    required this.quantity,
    required this.subTotal,
    required this.variantImage,
  });

  final String id;
  final String variantId;
  final String productName;
  final String size;
  final String color;
  final int price;
  final int quantity;
  final int subTotal;
  final String variantImage;

  String get variantLabel {
    final parts = <String>[
      if (size.isNotEmpty) 'Size: $size',
      if (color.isNotEmpty) color,
    ];
    return parts.join(' | ');
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final price = _toInt(json['price']);
    final quantity = _toInt(json['quantity']);
    final subTotal = _toInt(json['subTotal']);
    return OrderItemModel(
      id: (json['id'] ?? '').toString(),
      variantId: (json['variantId'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      size: (json['size'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      price: price,
      quantity: quantity,
      subTotal: subTotal == 0 ? price * quantity : subTotal,
      variantImage: (json['variantImage'] ?? '').toString(),
    );
  }
}

int _toInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse((value ?? '0').toString()) ?? 0;
}
