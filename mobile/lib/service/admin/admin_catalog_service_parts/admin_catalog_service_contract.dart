part of '../admin_catalog_service.dart';

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

  Future<CollectionModel> addVariantsToCollection({
    required CollectionModel collection,
    required List<String> variantIds,
  });

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
