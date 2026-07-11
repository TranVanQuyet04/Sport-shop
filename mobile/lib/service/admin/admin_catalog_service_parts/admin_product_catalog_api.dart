part of '../admin_catalog_service.dart';

mixin _AdminProductCatalogApi on _AdminCatalogApiBase {
  Future<List<ProductSummaryModel>> getProducts() async {
    final json = await _apiClient.getJson('/admin/products');
    return _parseList(
      json,
    ).map((item) => ProductSummaryModel.fromJson(item)).toList();
  }

  Future<ProductDetailModel> getProductDetail(String id) async {
    final json = await _apiClient.getJson('/admin/products/$id');
    return ProductDetailModel.fromJson(_parseObject(json));
  }

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

  Future<void> deleteProduct(String id) async {
    await _apiClient.deleteJson('/admin/products/$id');
  }

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

  Future<void> deleteVariant(String variantId) async {
    await _apiClient.deleteJson('/admin/products/variants/$variantId');
  }

  Future<void> updateVariantStock({
    required String variantId,
    required int quantity,
  }) async {
    await _apiClient.patchJson(
      '/admin/products/variants/$variantId/stock',
      queryParameters: {'quantity': quantity},
    );
  }
}
