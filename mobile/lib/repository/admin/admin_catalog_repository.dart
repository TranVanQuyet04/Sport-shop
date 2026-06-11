import '../../model/admin/admin_lookup_model.dart';
import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';

abstract interface class AdminCatalogRepository {
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
