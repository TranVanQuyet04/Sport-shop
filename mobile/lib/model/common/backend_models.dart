import '../../core/utils/image_url_utils.dart';

class BrandModel {
  const BrandModel({
    required this.id,
    required this.name,
    this.slug = '',
    this.logo = '',
    this.description = '',
    this.banner = '',
    this.isActive = true,
  });

  final String id;
  final String name;
  final String slug;
  final String logo;
  final String description;
  final String banner;
  final bool isActive;

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
    id: (json['id'] ?? '').toString(),
    name: (json['brandName'] ?? json['name'] ?? '').toString(),
    slug: (json['slug'] ?? '').toString(),
    logo: ImageUrlUtils.sanitize(json['logo']),
    description: (json['description'] ?? '').toString(),
    banner: ImageUrlUtils.sanitize(json['brandBanner'] ?? json['banner']),
    isActive: (json['isActive'] ?? json['active']) != false,
  );
}

class SportModel {
  const SportModel({
    required this.id,
    required this.name,
    this.description = '',
  });

  final String id;
  final String name;
  final String description;

  factory SportModel.fromJson(Map<String, dynamic> json) => SportModel(
    id: (json['id'] ?? '').toString(),
    name: (json['sportName'] ?? json['name'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
  );
}

class NavigationCategoryModel {
  const NavigationCategoryModel({
    required this.id,
    required this.name,
    required this.children,
  });

  final String id;
  final String name;
  final List<NavigationCategoryModel> children;

  factory NavigationCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    return NavigationCategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['categoryName'] ?? '').toString(),
      children: rawChildren is List
          ? rawChildren
                .whereType<Map>()
                .map(
                  (item) => NavigationCategoryModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class PaymentResponseModel {
  const PaymentResponseModel({
    required this.status,
    required this.message,
    required this.paymentUrl,
  });

  final String status;
  final String message;
  final String paymentUrl;

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    final source = json['result'] is Map
        ? Map<String, dynamic>.from(json['result'] as Map)
        : json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return PaymentResponseModel(
      status: (source['status'] ?? '').toString(),
      message: (source['message'] ?? '').toString(),
      paymentUrl: (source['paymentUrl'] ?? '').toString(),
    );
  }
}
