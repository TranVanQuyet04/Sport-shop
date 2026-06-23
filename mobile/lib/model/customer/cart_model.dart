class CartModel {
  const CartModel({
    required this.id,
    required this.totalPrice,
    required this.totalItems,
    required this.items,
  });

  final String id;
  final int totalPrice;
  final int totalItems;
  final List<CartItemModel> items;

  bool get isEmpty => items.isEmpty;

  int get computedTotalPrice {
    return items.fold<int>(0, (total, item) => total + item.subTotal);
  }

  factory CartModel.empty() {
    return const CartModel(id: '', totalPrice: 0, totalItems: 0, items: []);
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final source = json['result'] is Map
        ? Map<String, dynamic>.from(json['result'] as Map)
        : json;
    final rawItems = source['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) =>
                    CartItemModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <CartItemModel>[];

    return CartModel(
      id: (source['id'] ?? '').toString(),
      totalPrice: _toInt(source['totalPrice']),
      totalItems: _toInt(
        source['totalItems'] ??
            items.fold<int>(0, (total, item) => total + item.quantity),
      ),
      items: items,
    );
  }
}

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.variantId,
    required this.productName,
    required this.size,
    required this.color,
    required this.price,
    required this.quantity,
    required this.subTotal,
    required this.imageUrl,
    required this.maxStock,
  });

  final String id;
  final String variantId;
  final String productName;
  final String size;
  final String color;
  final int price;
  final int quantity;
  final int subTotal;
  final String imageUrl;
  final int maxStock;

  String get variantLabel {
    final parts = <String>[
      if (size.isNotEmpty) 'Size: $size',
      if (color.isNotEmpty) color,
    ];
    return parts.join(' | ');
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final price = _toInt(json['price']);
    final quantity = _toInt(json['quantity']);
    final subTotal = _toInt(json['subTotal']);

    return CartItemModel(
      id: (json['id'] ?? '').toString(),
      variantId: (json['variantId'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      size: (json['size'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      price: price,
      quantity: quantity,
      subTotal: subTotal == 0 ? price * quantity : subTotal,
      imageUrl: (json['imageUrl'] ?? '').toString(),
      maxStock: _toInt(json['maxStock']),
    );
  }
}

int _toInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse((value ?? '0').toString()) ?? 0;
}
