part of '../admin_catalog_service.dart';

mixin _AdminSportCollectionApi on _AdminCatalogApiBase {
  Future<List<SportModel>> getSports() async {
    final json = await _apiClient.getJson(ApiEndpoints.adminSports);
    return _parseList(json).map((item) => SportModel.fromJson(item)).toList();
  }

  Future<SportModel> getSportDetail(String id) async {
    final json = await _apiClient.getJson('${ApiEndpoints.adminSports}/$id');
    return SportModel.fromJson(_parseObject(json));
  }

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

  Future<void> deleteSport(String id) async {
    await _apiClient.deleteJson('${ApiEndpoints.adminSports}/$id');
  }

  Future<List<CollectionModel>> getCollections() async {
    final json = await _apiClient.getJson(ApiEndpoints.collections);
    return _parseList(
      json,
    ).map((item) => CollectionModel.fromJson(item)).toList();
  }

  Future<CollectionModel> addVariantsToCollection({
    required CollectionModel collection,
    required List<String> variantIds,
  }) async {
    final mergedVariantIds = {
      ...collection.variants.map((variant) => variant.id),
      ...variantIds,
    }.where((id) => id.isNotEmpty).toList(growable: false);

    final json = await _apiClient.putJson(
      '${ApiEndpoints.adminCollections}/${collection.id}',
      data: {
        'name': collection.name,
        'slug': collection.slug,
        'description': collection.description,
        'imageUrl': collection.imageUrl,
        'type': collection.type,
        'isActive': collection.isActive,
        'startDate': collection.startDate?.toIso8601String().split('T').first,
        'endDate': collection.endDate?.toIso8601String().split('T').first,
        'variantIds': _parseVariantIds(mergedVariantIds),
      },
    );
    return CollectionModel.fromJson(_parseObject(json));
  }

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
        'variantIds': _parseVariantIds(variantIds),
      },
    );
    return CollectionModel.fromJson(_parseObject(json));
  }

  Future<CollectionModel> updateCollection({
    required String id,
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
    final json = await _apiClient.putJson(
      '${ApiEndpoints.adminCollections}/$id',
      data: {
        'name': name,
        'slug': slug,
        'description': description,
        'imageUrl': imageUrl,
        'type': type,
        'isActive': isActive,
        'startDate': startDate,
        'endDate': endDate,
        'variantIds': _parseVariantIds(variantIds),
      },
    );
    return CollectionModel.fromJson(_parseObject(json));
  }

  Future<void> deleteCollection(String id) async {
    await _apiClient.deleteJson('${ApiEndpoints.adminCollections}/$id');
  }

  Future<Map<String, dynamic>> suggestProduct({
    required String productName,
    required String description,
  }) async {
    return _apiClient.postJson(
      '/admin/products/ai-suggest',
      data: {'productName': productName, 'description': description},
    );
  }

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
}
