import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';
import '../../service/customer/product_service.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._productService);

  final ProductService _productService;

  @override
  Future<List<ProductSummaryModel>> getRecommendedProducts() {
    return _productService.getRecommendedProducts();
  }

  @override
  Future<ProductDetailModel> getProductDetail(String productId) {
    return _productService.getProductDetail(productId);
  }
}
