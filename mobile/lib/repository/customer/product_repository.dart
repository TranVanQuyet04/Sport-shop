import '../../model/common/backend_models.dart';
import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';

abstract interface class ProductRepository {
  Future<List<ProductSummaryModel>> getRecommendedProducts({
    String? categoryId,
    String? brandId,
    String? sportId,
  });

  Future<ProductDetailModel> getProductDetail(String productId);

  Future<List<BrandModel>> getPublicBrands();
}
