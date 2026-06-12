import '../../model/admin/admin_lookup_model.dart';
import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';
import '../../service/admin/admin_catalog_service.dart';
import 'admin_catalog_repository.dart';

class AdminCatalogRepositoryImpl implements AdminCatalogRepository {
  const AdminCatalogRepositoryImpl(this._adminCatalogService);

  final AdminCatalogService _adminCatalogService;

  @override
  Future<List<ProductSummaryModel>> getProducts() =>
      _adminCatalogService.getProducts();

  @override
  Future<ProductDetailModel> getProductDetail(String id) =>
      _adminCatalogService.getProductDetail(id);

  @override
  Future<ProductDetailModel> createProduct({
    required String name,
    required String description,
    required String categoryName,
    required String brandName,
    required String sportName,
    required List<Map<String, dynamic>> variants,
  }) {
    return _adminCatalogService.createProduct(
      name: name,
      description: description,
      categoryName: categoryName,
      brandName: brandName,
      sportName: sportName,
      variants: variants,
    );
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
  }) {
    return _adminCatalogService.updateProduct(
      id: id,
      name: name,
      description: description,
      categoryName: categoryName,
      brandName: brandName,
      sportName: sportName,
      variants: variants,
    );
  }

  @override
  Future<void> deleteProduct(String id) =>
      _adminCatalogService.deleteProduct(id);

  @override
  Future<ProductVariantModel> addVariant({
    required String productId,
    required Map<String, dynamic> variant,
  }) {
    return _adminCatalogService.addVariant(
      productId: productId,
      variant: variant,
    );
  }

  @override
  Future<ProductVariantModel> updateVariant({
    required String variantId,
    required Map<String, dynamic> variant,
  }) {
    return _adminCatalogService.updateVariant(
      variantId: variantId,
      variant: variant,
    );
  }

  @override
  Future<void> deleteVariant(String variantId) =>
      _adminCatalogService.deleteVariant(variantId);

  @override
  Future<void> updateVariantStock({
    required String variantId,
    required int quantity,
  }) {
    return _adminCatalogService.updateVariantStock(
      variantId: variantId,
      quantity: quantity,
    );
  }

  @override
  Future<List<AdminCategoryModel>> getCategories() =>
      _adminCatalogService.getCategories();

  @override
  Future<AdminCategoryModel> createCategory({
    required String name,
    required String description,
    String? parentId,
  }) {
    return _adminCatalogService.createCategory(
      name: name,
      description: description,
      parentId: parentId,
    );
  }

  @override
  Future<AdminCategoryModel> updateCategory({
    required String id,
    required String name,
    required String description,
    String? parentId,
  }) {
    return _adminCatalogService.updateCategory(
      id: id,
      name: name,
      description: description,
      parentId: parentId,
    );
  }

  @override
  Future<void> deleteCategory(String id) =>
      _adminCatalogService.deleteCategory(id);

  @override
  Future<List<AdminBrandModel>> getBrands() => _adminCatalogService.getBrands();

  @override
  Future<AdminBrandModel> createBrand({
    required String name,
    required String description,
    required String logo,
    required bool isActive,
  }) {
    return _adminCatalogService.createBrand(
      name: name,
      description: description,
      logo: logo,
      isActive: isActive,
    );
  }

  @override
  Future<AdminBrandModel> updateBrand({
    required String id,
    required String name,
    required String description,
    required String logo,
    required bool isActive,
  }) {
    return _adminCatalogService.updateBrand(
      id: id,
      name: name,
      description: description,
      logo: logo,
      isActive: isActive,
    );
  }

  @override
  Future<void> deleteBrand(String id) => _adminCatalogService.deleteBrand(id);

  @override
  Future<List<AdminUserModel>> getUsers() => _adminCatalogService.getUsers();

  @override
  Future<AdminUserModel> createUser({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String roleName,
  }) {
    return _adminCatalogService.createUser(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
      roleName: roleName,
    );
  }

  @override
  Future<AdminUserModel> updateUser({
    required String id,
    required String fullName,
    required String phoneNumber,
    required String roleName,
    required bool status,
  }) {
    return _adminCatalogService.updateUser(
      id: id,
      fullName: fullName,
      phoneNumber: phoneNumber,
      roleName: roleName,
      status: status,
    );
  }

  @override
  Future<void> deleteUser(String id) => _adminCatalogService.deleteUser(id);
}
