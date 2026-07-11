import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../model/common/backend_models.dart';
import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';

abstract interface class ProductService {
  Future<List<ProductSummaryModel>> getRecommendedProducts({
    String? categoryId,
    String? brandId,
    String? sportId,
  });

  Future<ProductDetailModel> getProductDetail(String productId);

  Future<List<BrandModel>> getPublicBrands();
}

class ProductApiService implements ProductService {
  const ProductApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ProductSummaryModel>> getRecommendedProducts({
    String? categoryId,
    String? brandId,
    String? sportId,
  }) async {
    final json = await _apiClient.getJson(
      ApiEndpoints.products,
      queryParameters: {
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': int.tryParse(categoryId) ?? categoryId,
        if (brandId != null && brandId.isNotEmpty)
          'brandId': int.tryParse(brandId) ?? brandId,
        if (sportId != null && sportId.isNotEmpty)
          'sportId': int.tryParse(sportId) ?? sportId,
      },
    );
    final rawItems = json is List
        ? json
        : json['result'] ?? json['data'] ?? json['content'] ?? [];

    if (rawItems is! List) {
      return const [];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (item) =>
              ProductSummaryModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<ProductDetailModel> getProductDetail(String productId) async {
    final json = await _apiClient.getJson(
      '${ApiEndpoints.products}/$productId',
    );
    final result = json['result'];
    final source = result is Map ? Map<String, dynamic>.from(result) : json;
    return ProductDetailModel.fromJson(source);
  }

  @override
  Future<List<BrandModel>> getPublicBrands() async {
    final json = await _apiClient.getJson(ApiEndpoints.productBrands);
    final rawItems = json['result'] ?? json['data'] ?? json;
    if (rawItems is! List) {
      return const [];
    }
    return rawItems
        .whereType<Map>()
        .map((item) => BrandModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
