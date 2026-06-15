import 'package:flutter/foundation.dart';

import '../../model/customer/product_summary_model.dart';
import '../../repository/customer/product_repository.dart';

class CustomerHomeController extends ChangeNotifier {
  CustomerHomeController({required this.productRepository});

  final ProductRepository productRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<ProductSummaryModel> _recommendedProducts = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductSummaryModel> get recommendedProducts => _recommendedProducts;

  Future<void> loadHome() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recommendedProducts = await productRepository.getRecommendedProducts();
    } catch (error) {
      _recommendedProducts = const [];
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
