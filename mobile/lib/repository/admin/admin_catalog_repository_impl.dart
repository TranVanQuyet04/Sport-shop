import '../../model/admin/admin_lookup_model.dart';
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
}
