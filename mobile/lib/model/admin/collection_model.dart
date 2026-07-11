import '../../core/utils/image_url_utils.dart';
import '../customer/product_detail_model.dart';

class CollectionModel {
  const CollectionModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.isActive,
    this.startDate,
    this.endDate,
    required this.variants,
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final String type;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<ProductVariantModel> variants;

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variants'];
    return CollectionModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: ImageUrlUtils.sanitize(json['imageUrl']),
      type: (json['type'] ?? '').toString(),
      isActive: json['isActive'] != false,
      startDate: DateTime.tryParse((json['startDate'] ?? '').toString()),
      endDate: DateTime.tryParse((json['endDate'] ?? '').toString()),
      variants: rawVariants is List
          ? rawVariants
                .whereType<Map>()
                .map(
                  (item) => ProductVariantModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }
}
