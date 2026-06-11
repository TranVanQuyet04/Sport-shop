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
  bool isSubmitting = false;
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

  Future<bool> saveCategory({
    String? id,
    required String name,
    required String description,
    String? parentId,
  }) {
    return _submit(() async {
      if (id == null || id.isEmpty) {
        await adminCatalogRepository.createCategory(
          name: name,
          description: description,
          parentId: parentId,
        );
      } else {
        await adminCatalogRepository.updateCategory(
          id: id,
          name: name,
          description: description,
          parentId: parentId,
        );
      }
      categories = await adminCatalogRepository.getCategories();
    });
  }

  Future<bool> deleteCategory(String id) {
    return _submit(() async {
      await adminCatalogRepository.deleteCategory(id);
      categories = await adminCatalogRepository.getCategories();
    });
  }

  Future<bool> saveBrand({
    String? id,
    required String name,
    required String description,
    required String logo,
    required bool isActive,
  }) {
    return _submit(() async {
      if (id == null || id.isEmpty) {
        await adminCatalogRepository.createBrand(
          name: name,
          description: description,
          logo: logo,
          isActive: isActive,
        );
      } else {
        await adminCatalogRepository.updateBrand(
          id: id,
          name: name,
          description: description,
          logo: logo,
          isActive: isActive,
        );
      }
      brands = await adminCatalogRepository.getBrands();
    });
  }

  Future<bool> deleteBrand(String id) {
    return _submit(() async {
      await adminCatalogRepository.deleteBrand(id);
      brands = await adminCatalogRepository.getBrands();
    });
  }

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

  Future<bool> _submit(Future<void> Function() action) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
