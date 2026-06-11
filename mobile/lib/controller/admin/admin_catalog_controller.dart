import 'package:flutter/foundation.dart';

import '../../model/admin/admin_lookup_model.dart';
import '../../model/customer/product_summary_model.dart';
import '../../repository/admin/admin_catalog_repository.dart';

class AdminCatalogController extends ChangeNotifier {
  AdminCatalogController({required this.adminCatalogRepository});

  final AdminCatalogRepository adminCatalogRepository;

  List<ProductSummaryModel> products = const [];
  List<AdminCategoryModel> categories = const [];
  List<AdminBrandModel> brands = const [];
  List<AdminUserModel> users = const [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadProducts() =>
      _load(() async => products = await adminCatalogRepository.getProducts());

  Future<void> loadCategories() => _load(
    () async => categories = await adminCatalogRepository.getCategories(),
  );

  Future<void> loadBrands() =>
      _load(() async => brands = await adminCatalogRepository.getBrands());

  Future<void> loadUsers() =>
      _load(() async => users = await adminCatalogRepository.getUsers());

  Future<void> _load(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
