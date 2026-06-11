import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';

abstract interface class ProductService {
  Future<List<ProductSummaryModel>> getRecommendedProducts();

  Future<ProductDetailModel> getProductDetail(String productId);
}

class ProductApiService implements ProductService {
  const ProductApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ProductSummaryModel>> getRecommendedProducts() async {
    final json = await _apiClient.getJson(ApiEndpoints.products);
    final rawItems = json['result'] ?? json['data'] ?? json['content'] ?? [];

    if (rawItems is! List) {
      return const [];
    }

    return rawItems
        .whereType<Map>()
        .map((item) => ProductSummaryModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<ProductDetailModel> getProductDetail(String productId) async {
    final json = await _apiClient.getJson('${ApiEndpoints.products}/$productId');
    final result = json['result'];
    final source = result is Map ? Map<String, dynamic>.from(result) : json;
    return ProductDetailModel.fromJson(source);
  }
}
