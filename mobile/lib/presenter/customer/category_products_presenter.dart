import 'package:flutter/foundation.dart';

import '../../model/customer/product_summary_model.dart';
import '../../repository/customer/product_repository.dart';

class CategoryProductsPresenter extends ChangeNotifier {
  CategoryProductsPresenter({
    required this.productRepository,
    required this.categoryId,
  });

  final ProductRepository productRepository;
  final String categoryId;

  bool _isLoading = false;
  String? _errorMessage;
  List<ProductSummaryModel> _products = const [];
  String _selectedProductId = '';
  String _selectedColor = '';
  int _catalogMinPrice = 0;
  int _catalogMaxPrice = 0;
  int _minPrice = 0;
  int _maxPrice = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedProductId => _selectedProductId;
  String get selectedColor => _selectedColor;
  int get catalogMinPrice => _catalogMinPrice;
  int get catalogMaxPrice => _catalogMaxPrice;
  int get minPrice => _minPrice;
  int get maxPrice => _maxPrice;

  bool get hasActiveFilters =>
      _selectedProductId.isNotEmpty ||
      _selectedColor.isNotEmpty ||
      _minPrice != _catalogMinPrice ||
      _maxPrice != _catalogMaxPrice;

  List<ProductSummaryModel> get availableProducts {
    final products = List<ProductSummaryModel>.of(_products);
    products.sort((left, right) => left.name.compareTo(right.name));
    return products;
  }

  String get selectedProductName {
    for (final product in _products) {
      if (product.id == _selectedProductId) {
        return product.name;
      }
    }
    return '';
  }

  List<String> get availableColors {
    final colorsByKey = <String, String>{};
    for (final color in _products.expand((product) => product.colors)) {
      colorsByKey.putIfAbsent(color.toLowerCase(), () => color);
    }
    final colors = colorsByKey.values.toList(growable: false);
    return colors..sort((left, right) => left.compareTo(right));
  }

  List<ProductSummaryModel> get filteredProducts {
    final selectedColor = _selectedColor.toLowerCase();
    return _products
        .where((product) {
          final matchesProduct =
              _selectedProductId.isEmpty || product.id == _selectedProductId;
          final matchesColor =
              selectedColor.isEmpty ||
              product.colors.any(
                (color) => color.toLowerCase() == selectedColor,
              );
          final matchesPrice =
              product.price >= _minPrice && product.price <= _maxPrice;
          return matchesProduct && matchesColor && matchesPrice;
        })
        .toList(growable: false);
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await productRepository.getRecommendedProducts(
        categoryId: categoryId.isEmpty ? null : categoryId,
      );
      _resetPriceBounds();
    } catch (error) {
      _products = const [];
      _errorMessage = error.toString();
      _resetPriceBounds();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void applyFilters({
    String productId = '',
    required String color,
    required int minPrice,
    required int maxPrice,
  }) {
    _selectedProductId = productId;
    _selectedColor = color;
    _minPrice = minPrice.clamp(_catalogMinPrice, _catalogMaxPrice);
    _maxPrice = maxPrice.clamp(_minPrice, _catalogMaxPrice);
    notifyListeners();
  }

  void clearFilters() {
    _selectedProductId = '';
    _selectedColor = '';
    _minPrice = _catalogMinPrice;
    _maxPrice = _catalogMaxPrice;
    notifyListeners();
  }

  void _resetPriceBounds() {
    if (_products.isEmpty) {
      _catalogMinPrice = 0;
      _catalogMaxPrice = 0;
    } else {
      _catalogMinPrice = _products
          .map((product) => product.price)
          .reduce((left, right) => left < right ? left : right);
      _catalogMaxPrice = _products
          .map((product) => product.price)
          .reduce((left, right) => left > right ? left : right);
    }
    _selectedProductId = '';
    _selectedColor = '';
    _minPrice = _catalogMinPrice;
    _maxPrice = _catalogMaxPrice;
  }
}
