class OrderModel {
  const OrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.paymentMethod,
    required this.recipientName,
    required this.phoneNumber,
    required this.shippingAddress,
    required this.note,
  });

  final String id;
  final String status;
  final int totalAmount;
  final String paymentMethod;
  final String recipientName;
  final String phoneNumber;
  final String shippingAddress;
  final String note;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final source = json['result'] is Map
        ? Map<String, dynamic>.from(json['result'] as Map)
        : json;
    return OrderModel(
      id: (source['id'] ?? '').toString(),
      status: (source['status'] ?? '').toString(),
      totalAmount: _toInt(source['totalAmount']),
      paymentMethod: (source['paymentMethod'] ?? '').toString(),
      recipientName: (source['recipientName'] ?? '').toString(),
      phoneNumber: (source['phoneNumber'] ?? '').toString(),
      shippingAddress: (source['shippingAddress'] ?? '').toString(),
      note: (source['note'] ?? '').toString(),
    );
  }
}

int _toInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse((value ?? '0').toString()) ?? 0;
}
