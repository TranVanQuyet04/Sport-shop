import 'package:flutter/foundation.dart';

import '../../model/customer/product_summary_model.dart';
import '../../repository/customer/product_repository.dart';

class CustomerHomeController extends ChangeNotifier {
  CustomerHomeController({required this.productRepository});

  final ProductRepository productRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<ProductSummaryModel> _recommendedProducts = const [
    ProductSummaryModel(
      id: 'nike-air-max-270',
      name: 'Nike Air Zoom Alpha',
      category: 'Giày chạy bộ nam',
      price: 2450000,
      brand: 'Nike',
      rating: 4.9,
      isNew: true,
    ),
    ProductSummaryModel(
      id: 'adidas-terrex-wind',
      name: 'Adidas Terrex Wind',
      category: 'Áo khoác thể thao',
      price: 1890000,
      brand: 'Adidas',
      rating: 4.8,
    ),
    ProductSummaryModel(
      id: 'puma-training-tights',
      name: 'Puma Pro Training Tights',
      category: 'Quần tập luyện',
      price: 950000,
      brand: 'Puma',
      rating: 4.7,
    ),
    ProductSummaryModel(
      id: 'dry-fit-performance',
      name: 'Dry-Fit Performance Tee',
      category: 'Áo thể thao',
      price: 450000,
      brand: 'Nike',
      rating: 4.5,
    ),
  ];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductSummaryModel> get recommendedProducts => _recommendedProducts;

  Future<void> loadHome() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final products = await productRepository.getRecommendedProducts();
      if (products.isNotEmpty) {
        _recommendedProducts = products;
      }
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
