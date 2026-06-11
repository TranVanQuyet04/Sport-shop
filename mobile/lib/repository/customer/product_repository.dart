import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';

abstract interface class ProductRepository {
  Future<List<ProductSummaryModel>> getRecommendedProducts();

  Future<ProductDetailModel> getProductDetail(String productId);
}
