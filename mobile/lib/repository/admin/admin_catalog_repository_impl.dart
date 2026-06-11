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
  Future<List<AdminBrandModel>> getBrands() => _adminCatalogService.getBrands();

  @override
  Future<List<AdminUserModel>> getUsers() => _adminCatalogService.getUsers();
}
