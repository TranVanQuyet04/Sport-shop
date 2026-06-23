import '../../core/network/api_client.dart';
import '../../core/auth/role_mapper.dart';
import '../../core/network/api_endpoints.dart';
import '../../model/admin/collection_model.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/common/backend_models.dart';
import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';

abstract interface class AdminCatalogService {
  Future<List<ProductSummaryModel>> getProducts();

  Future<ProductDetailModel> getProductDetail(String id);

  Future<ProductDetailModel> createProduct({
    required String name,
    required String description,
    required String categoryName,
    required String brandName,
    required String sportName,
    required List<Map<String, dynamic>> variants,
  });

  Future<ProductSummaryModel> updateProduct({
    required String id,
    required String name,
    required String description,
    required String categoryName,
    required String brandName,
    required String sportName,
    required List<Map<String, dynamic>> variants,
  });

  Future<void> deleteProduct(String id);

  Future<ProductVariantModel> addVariant({
    required String productId,
    required Map<String, dynamic> variant,
  });

  Future<ProductVariantModel> updateVariant({
    required String variantId,
    required Map<String, dynamic> variant,
  });

  Future<void> deleteVariant(String variantId);

  Future<void> updateVariantStock({
    required String variantId,
    required int quantity,
  });

  Future<List<AdminCategoryModel>> getCategories();

  Future<AdminCategoryModel> getCategoryDetail(String id);

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

  Future<List<AdminRoleModel>> getRoles();

  Future<AdminUserModel> getUserDetail(String id);

  Future<AdminUserModel> createUser({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String roleName,
  });

  Future<AdminUserModel> updateUser({
    required String id,
    required String fullName,
    required String phoneNumber,
    required String roleName,
    required bool status,
  });

  Future<void> deleteUser(String id);

  Future<List<SportModel>> getSports();

  Future<SportModel> getSportDetail(String id);

  Future<SportModel> createSport({
    required String name,
    required String description,
  });

  Future<SportModel> updateSport({
    required String id,
    required String name,
    required String description,
  });

  Future<void> deleteSport(String id);

  Future<List<CollectionModel>> getCollections();

  Future<CollectionModel> createCollection({
    required String name,
    required String slug,
    required String description,
    required String imageUrl,
    required String type,
    required bool isActive,
    String? startDate,
    String? endDate,
    required List<String> variantIds,
  });

  Future<void> deleteCollection(String id);

  Future<Map<String, dynamic>> suggestProduct({
    required String productName,
    required String description,
  });

  Future<ProductDetailModel> confirmProduct({
    required String name,
    required String description,
    required String categoryName,
    required String brandName,
    required String sportName,
    required List<Map<String, dynamic>> variants,
  });
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
  Future<ProductDetailModel> getProductDetail(String id) async {
    final json = await _apiClient.getJson('/admin/products/$id');
    return ProductDetailModel.fromJson(_parseObject(json));
  }

  @override
  Future<ProductDetailModel> createProduct({
    required String name,
    required String description,
    required String categoryName,
    required String brandName,
    required String sportName,
    required List<Map<String, dynamic>> variants,
  }) async {
    final json = await _apiClient.postJson(
      '/admin/products',
      data: _productPayload(
        name: name,
        description: description,
        categoryName: categoryName,
        brandName: brandName,
        sportName: sportName,
        variants: variants,
      ),
    );
    return ProductDetailModel.fromJson(_parseObject(json));
  }

  @override
  Future<ProductSummaryModel> updateProduct({
    required String id,
    required String name,
    required String description,
    required String categoryName,
    required String brandName,
    required String sportName,
    required List<Map<String, dynamic>> variants,
  }) async {
    final json = await _apiClient.putJson(
      '/admin/products/$id',
      data: _productPayload(
        name: name,
        description: description,
        categoryName: categoryName,
        brandName: brandName,
        sportName: sportName,
        variants: variants,
      ),
    );
    return ProductSummaryModel.fromJson(_parseObject(json));
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _apiClient.deleteJson('/admin/products/$id');
  }

  @override
  Future<ProductVariantModel> addVariant({
    required String productId,
    required Map<String, dynamic> variant,
  }) async {
    final json = await _apiClient.postJson(
      '/admin/products/$productId/variants',
      data: variant,
    );
    return ProductVariantModel.fromJson(_parseObject(json));
  }

  @override
  Future<ProductVariantModel> updateVariant({
    required String variantId,
    required Map<String, dynamic> variant,
  }) async {
    final json = await _apiClient.putJson(
      '/admin/products/variants/$variantId',
      data: variant,
    );
    return ProductVariantModel.fromJson(_parseObject(json));
  }

  @override
  Future<void> deleteVariant(String variantId) async {
    await _apiClient.deleteJson('/admin/products/variants/$variantId');
  }

  @override
  Future<void> updateVariantStock({
    required String variantId,
    required int quantity,
  }) async {
    await _apiClient.patchJson(
      '/admin/products/variants/$variantId/stock',
      queryParameters: {'quantity': quantity},
    );
  }

  @override
  Future<List<AdminCategoryModel>> getCategories() async {
    final json = await _apiClient.getJson('/admin/categories');
    return _parseList(
      json,
    ).map((item) => AdminCategoryModel.fromJson(item)).toList();
  }

  @override
  Future<AdminCategoryModel> getCategoryDetail(String id) async {
    final json = await _apiClient.getJson('/admin/categories/$id');
    return AdminCategoryModel.fromJson(_parseObject(json));
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

  @override
  Future<List<AdminRoleModel>> getRoles() async {
    final json = await _apiClient.getJson('/admin/roles');
    return _parseList(json).map((item) => AdminRoleModel.fromJson(item)).toList();
  }

  @override
  Future<AdminUserModel> getUserDetail(String id) async {
    final json = await _apiClient.getJson('/admin/users/$id');
    return AdminUserModel.fromJson(_parseObject(json));
  }

  @override
  Future<AdminUserModel> createUser({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String roleName,
  }) async {
    final json = await _apiClient.postJson(
      '/admin/users',
      data: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
        'roleName': RoleMapper.backendRoleName(roleName),
      },
    );
    return AdminUserModel.fromJson(_parseObject(json));
  }

  @override
  Future<AdminUserModel> updateUser({
    required String id,
    required String fullName,
    required String phoneNumber,
    required String roleName,
    required bool status,
  }) async {
    final json = await _apiClient.putJson(
      '/admin/users/$id',
      data: {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'roleName': RoleMapper.backendRoleName(roleName),
        'status': status,
      },
    );
    return AdminUserModel.fromJson(_parseObject(json));
  }

  @override
  Future<void> deleteUser(String id) async {
    await _apiClient.deleteJson('/admin/users/$id');
  }

  @override
  Future<List<SportModel>> getSports() async {
    final json = await _apiClient.getJson(ApiEndpoints.adminSports);
    return _parseList(json).map((item) => SportModel.fromJson(item)).toList();
  }

  @override
  Future<SportModel> getSportDetail(String id) async {
    final json = await _apiClient.getJson('${ApiEndpoints.adminSports}/$id');
    return SportModel.fromJson(_parseObject(json));
  }

  @override
  Future<SportModel> createSport({
    required String name,
    required String description,
  }) async {
    final json = await _apiClient.postJson(
      ApiEndpoints.adminSports,
      data: {'sportName': name, 'description': description},
    );
    return SportModel.fromJson(_parseObject(json));
  }

  @override
  Future<SportModel> updateSport({
    required String id,
    required String name,
    required String description,
  }) async {
    final json = await _apiClient.putJson(
      '${ApiEndpoints.adminSports}/$id',
      data: {'sportName': name, 'description': description},
    );
    return SportModel.fromJson(_parseObject(json));
  }

  @override
  Future<void> deleteSport(String id) async {
    await _apiClient.deleteJson('${ApiEndpoints.adminSports}/$id');
  }

  @override
  Future<List<CollectionModel>> getCollections() async {
    final json = await _apiClient.getJson(ApiEndpoints.collections);
    return _parseList(json)
        .map((item) => CollectionModel.fromJson(item))
        .toList();
  }

  @override
  Future<CollectionModel> createCollection({
    required String name,
    required String slug,
    required String description,
    required String imageUrl,
    required String type,
    required bool isActive,
    String? startDate,
    String? endDate,
    required List<String> variantIds,
  }) async {
    final json = await _apiClient.postJson(
      ApiEndpoints.adminCollections,
      data: {
        'name': name,
        'slug': slug,
        'description': description,
        'imageUrl': imageUrl,
        'type': type,
        'isActive': isActive,
        'startDate': startDate,
        'endDate': endDate,
        'variantIds': variantIds
            .map((id) => int.tryParse(id) ?? id)
            .toList(growable: false),
      },
    );
    return CollectionModel.fromJson(_parseObject(json));
  }

  @override
  Future<void> deleteCollection(String id) async {
    await _apiClient.deleteJson('${ApiEndpoints.adminCollections}/$id');
  }

  @override
  Future<Map<String, dynamic>> suggestProduct({
    required String productName,
    required String description,
  }) async {
    return _apiClient.postJson(
      '/admin/products/ai-suggest',
      data: {'productName': productName, 'description': description},
    );
  }

  @override
  Future<ProductDetailModel> confirmProduct({
    required String name,
    required String description,
    required String categoryName,
    required String brandName,
    required String sportName,
    required List<Map<String, dynamic>> variants,
  }) async {
    final json = await _apiClient.postJson(
      '/admin/products/admin-confirm',
      data: _productPayload(
        name: name,
        description: description,
        categoryName: categoryName,
        brandName: brandName,
        sportName: sportName,
        variants: variants,
      ),
    );
    return ProductDetailModel.fromJson(_parseObject(json));
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

  Map<String, dynamic> _productPayload({
    required String name,
    required String description,
    required String categoryName,
    required String brandName,
    required String sportName,
    required List<Map<String, dynamic>> variants,
  }) {
    return {
      'productName': name,
      'description': description,
      'categoryName': categoryName,
      'brandName': brandName,
      'sportName': sportName,
      'variants': variants,
    };
  }
}
