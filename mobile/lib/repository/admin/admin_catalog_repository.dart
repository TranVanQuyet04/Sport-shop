import '../../model/admin/admin_lookup_model.dart';
import '../../model/customer/product_summary_model.dart';

abstract interface class AdminCatalogRepository {
  Future<List<ProductSummaryModel>> getProducts();

  Future<List<AdminCategoryModel>> getCategories();

  Future<List<AdminBrandModel>> getBrands();

  Future<List<AdminUserModel>> getUsers();
}
