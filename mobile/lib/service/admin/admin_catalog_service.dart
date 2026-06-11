import '../../core/network/api_client.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/customer/product_summary_model.dart';

abstract interface class AdminCatalogService {
  Future<List<ProductSummaryModel>> getProducts();

  Future<List<AdminCategoryModel>> getCategories();

  Future<AdminCategoryModel> createCategory({
    required String name,
    required String description,
    String? parentId,
  });

  Future<AdminCategoryModel> updateCategory({
    required String id,
    required String name,
    required String description,
    String? parentId,
  });

  Future<void> deleteCategory(String id);

  Future<List<AdminBrandModel>> getBrands();

  Future<AdminBrandModel> createBrand({
    required String name,
    required String description,
    required String logo,
    required bool isActive,
  });

  Future<AdminBrandModel> updateBrand({
    required String id,
    required String name,
    required String description,
    required String logo,
    required bool isActive,
  });

  Future<void> deleteBrand(String id);

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
  Future<AdminCategoryModel> createCategory({
    required String name,
    required String description,
    String? parentId,
  }) async {
    final json = await _apiClient.postJson(
      '/admin/categories',
      data: {
        'categoryName': name,
        'description': description,
        'parentId': _nullableInt(parentId),
      },
    );
    return AdminCategoryModel.fromJson(_parseObject(json));
  }

  @override
  Future<AdminCategoryModel> updateCategory({
    required String id,
    required String name,
    required String description,
    String? parentId,
  }) async {
    final json = await _apiClient.putJson(
      '/admin/categories/$id',
      data: {
        'categoryName': name,
        'description': description,
        'parentId': _nullableInt(parentId),
      },
    );
    return AdminCategoryModel.fromJson(_parseObject(json));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _apiClient.deleteJson('/admin/categories/$id');
  }

  @override
  Future<List<AdminBrandModel>> getBrands() async {
    final json = await _apiClient.getJson('/brands');
    return _parseList(
      json,
    ).map((item) => AdminBrandModel.fromJson(item)).toList();
  }

  @override
  Future<AdminBrandModel> createBrand({
    required String name,
    required String description,
    required String logo,
    required bool isActive,
  }) async {
    final json = await _apiClient.postJson(
      '/brands',
      data: {
        'name': name,
        'slug': _slugify(name),
        'logo': logo,
        'description': description,
        'banner': '',
        'isActive': isActive,
      },
    );
    return AdminBrandModel.fromJson(_parseObject(json));
  }

  @override
  Future<AdminBrandModel> updateBrand({
    required String id,
    required String name,
    required String description,
    required String logo,
    required bool isActive,
  }) async {
    final json = await _apiClient.putJson(
      '/brands/$id',
      data: {
        'name': name,
        'slug': _slugify(name),
        'logo': logo,
        'description': description,
        'banner': '',
        'isActive': isActive,
      },
    );
    return AdminBrandModel.fromJson(_parseObject(json));
  }

  @override
  Future<void> deleteBrand(String id) async {
    await _apiClient.deleteJson('/brands/$id');
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
    if (rawItems is Map && rawItems['brands'] is List) {
      return (rawItems['brands'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (rawItems is! List) {
      return const [];
    }
    return rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Map<String, dynamic> _parseObject(Map<String, dynamic> json) {
    final rawItem = json['result'] ?? json['data'] ?? json;
    if (rawItem is Map) {
      return Map<String, dynamic>.from(rawItem);
    }
    return const {};
  }

  int? _nullableInt(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return int.tryParse(value.trim());
  }

  String _slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
