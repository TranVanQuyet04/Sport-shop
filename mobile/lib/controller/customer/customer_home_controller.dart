import 'package:flutter/foundation.dart';

import '../../core/mock/customer_demo_data.dart';
import '../../model/customer/product_summary_model.dart';
import '../../repository/customer/product_repository.dart';

class CustomerHomeController extends ChangeNotifier {
  CustomerHomeController({required this.productRepository});

  final ProductRepository productRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<ProductSummaryModel> _recommendedProducts = CustomerDemoData.products;

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
      } else {
        _recommendedProducts = CustomerDemoData.products;
      }
    } catch (error) {
      _errorMessage = error.toString();
      _recommendedProducts = CustomerDemoData.products;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
