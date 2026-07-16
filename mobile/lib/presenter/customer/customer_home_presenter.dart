import 'package:flutter/foundation.dart';

import '../../model/common/backend_models.dart';
import '../../model/customer/product_summary_model.dart';
import '../../repository/customer/navigation_repository.dart';
import '../../repository/customer/product_repository.dart';

class CustomerHomePresenter extends ChangeNotifier {
  CustomerHomePresenter({
    required this.productRepository,
    this.navigationRepository,
  });

  final ProductRepository productRepository;
  final NavigationRepository? navigationRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<ProductSummaryModel> _recommendedProducts = const [];
  List<NavigationCategoryModel> _categories = const [];
  List<BrandModel> _brands = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductSummaryModel> get recommendedProducts => _recommendedProducts;
  List<NavigationCategoryModel> get categories => _categories;
  List<BrandModel> get brands => _brands;

  Future<void> loadHome() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final errors = <Object>[];
    try {
      _recommendedProducts = await productRepository.getRecommendedProducts();
    } catch (error) {
      _recommendedProducts = const [];
      errors.add(error);
    }

    try {
      _brands = await productRepository.getPublicBrands();
    } catch (error) {
      _brands = const [];
      errors.add(error);
    }

    final navigationRepository = this.navigationRepository;
    if (navigationRepository != null) {
      try {
        _categories = await navigationRepository.getMainNavigation();
      } catch (error) {
        _categories = const [];
        errors.add(error);
      }
    }

    if (errors.isNotEmpty) {
      _errorMessage = errors.first.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProducts({
    String? categoryId,
    String? brandId,
    String? sportId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recommendedProducts = await productRepository.getRecommendedProducts(
        categoryId: categoryId,
        brandId: brandId,
        sportId: sportId,
      );
    } catch (error) {
      _recommendedProducts = const [];
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
