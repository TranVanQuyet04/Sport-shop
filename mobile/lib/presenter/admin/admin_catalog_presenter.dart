import 'package:flutter/foundation.dart';

import '../../core/utils/brand_logo_url_validator.dart';
import '../../model/admin/collection_model.dart';
import '../../model/admin/admin_lookup_model.dart';
import '../../model/common/backend_models.dart';
import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';
import '../../repository/admin/admin_catalog_repository.dart';

class AdminCatalogPresenter extends ChangeNotifier {
  AdminCatalogPresenter({required this.adminCatalogRepository});

  final AdminCatalogRepository adminCatalogRepository;

  List<ProductSummaryModel> products = const [];
  ProductDetailModel? selectedProduct;
  List<AdminCategoryModel> categories = const [];
  List<AdminBrandModel> brands = const [];
  List<AdminUserModel> users = const [];
  List<AdminRoleModel> roles = const [];
  List<SportModel> sports = const [];
  List<CollectionModel> collections = const [];
  AdminUserModel? selectedUser;
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  bool _disposed = false;
  String searchKeyword = '';

  void search(String keyword) {
    searchKeyword = keyword;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadProducts() => _load(() async {
    products = await adminCatalogRepository.getProducts();
  });

  Future<void> loadProductDetail(String id) => _load(() async {
    selectedProduct = await adminCatalogRepository.getProductDetail(id);
  });

  Future<bool> saveProduct({
    String? id,
    required String name,
    required String description,
    required String categoryName,
    required String brandName,
    required String sportName,
    required List<Map<String, dynamic>> variants,
  }) {
    return _submit(() async {
      if (id == null || id.isEmpty) {
        selectedProduct = await adminCatalogRepository.createProduct(
          name: name,
          description: description,
          categoryName: categoryName,
          brandName: brandName,
          sportName: sportName,
          variants: variants,
        );
      } else {
        await adminCatalogRepository.updateProduct(
          id: id,
          name: name,
          description: description,
          categoryName: categoryName,
          brandName: brandName,
          sportName: sportName,
          variants: variants,
        );
        selectedProduct = await adminCatalogRepository.getProductDetail(id);
      }
      products = await adminCatalogRepository.getProducts();
    });
  }

  Future<bool> deleteProduct(String id) {
    return _submit(() async {
      await adminCatalogRepository.deleteProduct(id);
      products = await adminCatalogRepository.getProducts();
    });
  }

  Future<bool> saveVariant({
    required String productId,
    String? variantId,
    required Map<String, dynamic> variant,
  }) {
    return _submit(() async {
      if (variantId == null || variantId.isEmpty) {
        await adminCatalogRepository.addVariant(
          productId: productId,
          variant: variant,
        );
      } else {
        await adminCatalogRepository.updateVariant(
          variantId: variantId,
          variant: variant,
        );
      }
      selectedProduct = await adminCatalogRepository.getProductDetail(
        productId,
      );
    });
  }

  Future<bool> deleteVariant({
    required String productId,
    required String variantId,
  }) {
    return _submit(() async {
      await adminCatalogRepository.deleteVariant(variantId);
      selectedProduct = await adminCatalogRepository.getProductDetail(
        productId,
      );
    });
  }

  Future<bool> updateVariantStock({
    required String productId,
    required String variantId,
    required int quantity,
  }) {
    return _submit(() async {
      await adminCatalogRepository.updateVariantStock(
        variantId: variantId,
        quantity: quantity,
      );
      selectedProduct = await adminCatalogRepository.getProductDetail(
        productId,
      );
    });
  }

  Future<void> loadCategories() => _load(() async {
    categories = await adminCatalogRepository.getCategories();
  });

  Future<void> loadBrands() => _load(() async {
    brands = await adminCatalogRepository.getBrands();
  });

  Future<void> loadUsers() => _load(() async {
    users = await adminCatalogRepository.getUsers();
  });

  Future<void> loadRoles() => _load(() async {
    roles = await adminCatalogRepository.getRoles();
  });

  Future<void> loadSports() => _load(() async {
    sports = await adminCatalogRepository.getSports();
  });

  Future<void> loadCollections() => _load(() async {
    collections = await adminCatalogRepository.getCollections();
  });

  Future<void> loadUserDetail(String id) => _load(() async {
    selectedUser = await adminCatalogRepository.getUserDetail(id);
  });

  Future<bool> saveUser({
    String? id,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String roleName,
    required bool status,
  }) {
    return _submit(() async {
      if (id == null || id.isEmpty) {
        await adminCatalogRepository.createUser(
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          password: password,
          confirmPassword: confirmPassword,
          roleName: roleName,
        );
      } else {
        await adminCatalogRepository.updateUser(
          id: id,
          fullName: fullName,
          phoneNumber: phoneNumber,
          roleName: roleName,
          status: status,
        );
        selectedUser = await adminCatalogRepository.getUserDetail(id);
      }
      users = await adminCatalogRepository.getUsers();
    });
  }

  Future<bool> deleteUser(String id) {
    return _submit(() async {
      await adminCatalogRepository.deleteUser(id);
      users = await adminCatalogRepository.getUsers();
    });
  }

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
    final logoError = BrandLogoUrlValidator.validate(logo);
    if (logoError != null) {
      errorMessage = logoError;
      _safeNotifyListeners();
      return Future.value(false);
    }
    final normalizedLogo = BrandLogoUrlValidator.normalize(logo);
    return _submit(() async {
      if (id == null || id.isEmpty) {
        await adminCatalogRepository.createBrand(
          name: name,
          description: description,
          logo: normalizedLogo,
          isActive: isActive,
        );
      } else {
        await adminCatalogRepository.updateBrand(
          id: id,
          name: name,
          description: description,
          logo: normalizedLogo,
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

  Future<bool> saveSport({
    String? id,
    required String name,
    required String description,
  }) {
    return _submit(() async {
      if (id == null || id.isEmpty) {
        await adminCatalogRepository.createSport(
          name: name,
          description: description,
        );
      } else {
        await adminCatalogRepository.updateSport(
          id: id,
          name: name,
          description: description,
        );
      }
      sports = await adminCatalogRepository.getSports();
    });
  }

  Future<bool> deleteSport(String id) {
    return _submit(() async {
      await adminCatalogRepository.deleteSport(id);
      sports = await adminCatalogRepository.getSports();
    });
  }

  Future<bool> createCollection({
    required String name,
    required String slug,
    required String description,
    required String imageUrl,
    required String type,
    required bool isActive,
    String? startDate,
    String? endDate,
    required List<String> variantIds,
  }) {
    return _submit(() async {
      await adminCatalogRepository.createCollection(
        name: name,
        slug: slug,
        description: description,
        imageUrl: imageUrl,
        type: type,
        isActive: isActive,
        startDate: startDate,
        endDate: endDate,
        variantIds: variantIds,
      );
      collections = await adminCatalogRepository.getCollections();
    });
  }

  Future<bool> updateCollection({
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
  }) {
    return _submit(() async {
      await adminCatalogRepository.updateCollection(
        id: id,
        name: name,
        slug: slug,
        description: description,
        imageUrl: imageUrl,
        type: type,
        isActive: isActive,
        startDate: startDate,
        endDate: endDate,
        variantIds: variantIds,
      );
      collections = await adminCatalogRepository.getCollections();
    });
  }

  Future<bool> deleteCollection(String id) {
    return _submit(() async {
      await adminCatalogRepository.deleteCollection(id);
      collections = await adminCatalogRepository.getCollections();
    });
  }

  Future<void> _load(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    _safeNotifyListeners();

    try {
      await action();
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> _submit(Future<void> Function() action) async {
    isSubmitting = true;
    errorMessage = null;
    _safeNotifyListeners();

    try {
      await action();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
      _safeNotifyListeners();
    }
  }
}
