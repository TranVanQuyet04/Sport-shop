class ProductDetailModel {
  const ProductDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    required this.sport,
    required this.variants,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final String brand;
  final String sport;
  final List<ProductVariantModel> variants;

  int get displayPrice => variants.isEmpty ? 0 : variants.first.price;
  List<String> get colors => variants.map((variant) => variant.color).where((value) => value.isNotEmpty).toSet().toList();
  List<String> get sizes => variants.map((variant) => variant.size).where((value) => value.isNotEmpty).toSet().toList();
  List<String> get imageUrls => variants.expand((variant) => variant.imageUrls).toSet().toList();

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variants'];
    final variants = rawVariants is List
        ? rawVariants
            .whereType<Map>()
            .map((item) => ProductVariantModel.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <ProductVariantModel>[];

    return ProductDetailModel(
      id: (json['id'] ?? json['productId'] ?? '').toString(),
      name: (json['productName'] ?? json['name'] ?? 'Sản phẩm').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['categoryName'] ?? json['category'] ?? 'Thể thao').toString(),
      brand: (json['brandName'] ?? json['brand'] ?? '').toString(),
      sport: (json['sportName'] ?? json['sport'] ?? '').toString(),
      variants: variants,
    );
  }
}

class ProductVariantModel {
  const ProductVariantModel({
    required this.id,
    required this.sku,
    required this.size,
    required this.color,
    required this.price,
    required this.stockQuantity,
    required this.imageUrls,
  });

  final String id;
  final String sku;
  final String size;
  final String color;
  final int price;
  final int stockQuantity;
  final List<String> imageUrls;

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['imageUrls'] ?? json['images'] ?? [];
    final images = rawImages is List ? rawImages.map((item) => item.toString()).toList() : <String>[];
    final priceValue = json['price'] ?? 0;

    return ProductVariantModel(
      id: (json['id'] ?? json['variantId'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      size: (json['size'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      price: priceValue is num ? priceValue.toInt() : int.tryParse(priceValue.toString()) ?? 0,
      stockQuantity: (json['stockQuantity'] is num) ? (json['stockQuantity'] as num).toInt() : int.tryParse((json['stockQuantity'] ?? '0').toString()) ?? 0,
      imageUrls: images,
    );
  }
}
