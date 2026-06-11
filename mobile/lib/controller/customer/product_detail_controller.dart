import 'package:flutter/foundation.dart';

import '../../model/customer/product_detail_model.dart';
import '../../repository/customer/product_repository.dart';

class ProductDetailController extends ChangeNotifier {
  ProductDetailController({
    required this.productRepository,
    required this.productId,
  });

  final ProductRepository productRepository;
  final String productId;

  bool _isLoading = false;
  String? _errorMessage;
  ProductDetailModel? _product;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProductDetailModel? get product => _product;

  Future<void> loadProduct() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _product = await productRepository.getProductDetail(productId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
