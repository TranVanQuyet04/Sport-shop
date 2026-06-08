import '../../model/customer/product_summary_model.dart';

abstract interface class ProductRepository {
  Future<List<ProductSummaryModel>> getRecommendedProducts();
}
