import '../../core/utils/image_url_utils.dart';

class ProductSummaryModel {
  const ProductSummaryModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.brand = '',
    this.sport = '',
    this.imageUrl = '',
    this.rating = 0,
    this.isNew = false,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final String brand;
  final String sport;
  final String imageUrl;
  final double rating;
  final bool isNew;

  bool get hasRating => rating > 0;

  factory ProductSummaryModel.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'] ?? json['salePrice'] ?? 0;

    return ProductSummaryModel(
      id: (json['id'] ?? json['productId'] ?? '').toString(),
      name: (json['name'] ?? json['productName'] ?? '').toString(),
      category: (json['categoryName'] ?? json['category'] ?? '').toString(),
      price: priceValue is num
          ? priceValue.toInt()
          : int.tryParse(priceValue.toString()) ?? 0,
      brand: (json['brandName'] ?? json['brand'] ?? '').toString(),
      sport: (json['sportName'] ?? json['sport'] ?? '').toString(),
      imageUrl: ImageUrlUtils.sanitize(json['image_url'] ?? json['imageUrl']),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0,
    );
  }
}
