import '../../core/network/api_client.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/customer/product_summary_model.dart';

abstract interface class AdminCatalogService {
  Future<List<ProductSummaryModel>> getProducts();

  Future<List<AdminCategoryModel>> getCategories();

  Future<List<AdminBrandModel>> getBrands();

  Future<List<AdminUserModel>> getUsers();
}

class AdminCatalogApiService implements AdminCatalogService {
  const AdminCatalogApiService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ProductSummaryModel>> getProducts() async {
    final json = await _apiClient.getJson('/admin/products');
    return _parseList(
      json,
    ).map((item) => ProductSummaryModel.fromJson(item)).toList();
  }

  @override
  Future<List<AdminCategoryModel>> getCategories() async {
    final json = await _apiClient.getJson('/admin/categories');
    return _parseList(
      json,
    ).map((item) => AdminCategoryModel.fromJson(item)).toList();
  }

  @override
  Future<List<AdminBrandModel>> getBrands() async {
    final json = await _apiClient.getJson('/brands');
    return _parseList(
      json,
    ).map((item) => AdminBrandModel.fromJson(item)).toList();
  }

  @override
  Future<List<AdminUserModel>> getUsers() async {
    final json = await _apiClient.getJson('/admin/users');
    return _parseList(
      json,
    ).map((item) => AdminUserModel.fromJson(item)).toList();
  }

  List<Map<String, dynamic>> _parseList(Map<String, dynamic> json) {
    final rawItems = json['result'] ?? json['data'] ?? json['content'] ?? json;
    if (rawItems is! List) {
      return const [];
    }
    return rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
