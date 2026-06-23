import '../../model/common/backend_models.dart';
import '../../model/customer/product_detail_model.dart';
import '../../model/customer/product_summary_model.dart';
import '../../service/customer/product_service.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._productService);

  final ProductService _productService;

  @override
  Future<List<ProductSummaryModel>> getRecommendedProducts({
    String? categoryId,
    String? brandId,
    String? sportId,
  }) {
    return _productService.getRecommendedProducts(
      categoryId: categoryId,
      brandId: brandId,
      sportId: sportId,
    );
  }

  @override
  Future<ProductDetailModel> getProductDetail(String productId) {
    return _productService.getProductDetail(productId);
  }

  @override
  Future<List<BrandModel>> getPublicBrands() {
    return _productService.getPublicBrands();
  }
}
