part of '../admin_catalog_service.dart';

mixin _AdminCategoryBrandApi on _AdminCatalogApiBase {
  Future<List<AdminCategoryModel>> getCategories() async {
    final json = await _apiClient.getJson('/admin/categories');
    return _parseList(
      json,
    ).map((item) => AdminCategoryModel.fromJson(item)).toList();
  }

  Future<AdminCategoryModel> getCategoryDetail(String id) async {
    final json = await _apiClient.getJson('/admin/categories/$id');
    return AdminCategoryModel.fromJson(_parseObject(json));
  }

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

  Future<void> deleteCategory(String id) async {
    await _apiClient.deleteJson('/admin/categories/$id');
  }

  Future<List<AdminBrandModel>> getBrands() async {
    final json = await _apiClient.getJson('/brands');
    return _parseList(
      json,
    ).map((item) => AdminBrandModel.fromJson(item)).toList();
  }

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

  Future<void> deleteBrand(String id) async {
    await _apiClient.deleteJson('/brands/$id');
  }
}
