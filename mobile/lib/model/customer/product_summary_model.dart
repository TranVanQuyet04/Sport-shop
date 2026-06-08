class ProductSummaryModel {
  const ProductSummaryModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.brand = '',
    this.rating = 4.8,
    this.isNew = false,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final String brand;
  final double rating;
  final bool isNew;

  factory ProductSummaryModel.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'] ?? json['salePrice'] ?? 0;

    return ProductSummaryModel(
      id: (json['id'] ?? json['productId'] ?? '').toString(),
      name: (json['name'] ?? json['productName'] ?? 'Sản phẩm').toString(),
      category: (json['categoryName'] ?? json['category'] ?? 'Thể thao').toString(),
      price: priceValue is num ? priceValue.toInt() : int.tryParse(priceValue.toString()) ?? 0,
      brand: (json['brandName'] ?? json['brand'] ?? '').toString(),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 4.8,
    );
  }
}
