import 'package:flutter_test/flutter_test.dart';
import 'package:sportswear_shop_mobile/model/common/backend_models.dart';
import 'package:sportswear_shop_mobile/model/customer/product_detail_model.dart';
import 'package:sportswear_shop_mobile/model/customer/product_summary_model.dart';
import 'package:sportswear_shop_mobile/presenter/customer/category_products_presenter.dart';
import 'package:sportswear_shop_mobile/repository/customer/product_repository.dart';

void main() {
  group('CategoryProductsPresenter', () {
    test('loads every product for the selected category', () async {
      final repository = _FakeProductRepository(_products);
      final presenter = CategoryProductsPresenter(
        productRepository: repository,
        categoryId: '5',
      );

      await presenter.loadProducts();

      expect(repository.requestedCategoryId, '5');
      expect(presenter.filteredProducts, hasLength(3));
      expect(presenter.catalogMinPrice, 450000);
      expect(presenter.catalogMaxPrice, 2200000);
    });

    test('filters products by variant color and price range', () async {
      final presenter = CategoryProductsPresenter(
        productRepository: _FakeProductRepository(_products),
        categoryId: '5',
      );
      await presenter.loadProducts();

      presenter.applyFilters(color: 'Đen', minPrice: 500000, maxPrice: 2000000);

      expect(presenter.filteredProducts.map((product) => product.id), ['1']);
      expect(presenter.hasActiveFilters, isTrue);
    });

    test('filters by an exact product in the current catalog', () async {
      final presenter = CategoryProductsPresenter(
        productRepository: _FakeProductRepository(_products),
        categoryId: '',
      );
      await presenter.loadProducts();

      presenter.applyFilters(
        productId: '2',
        color: '',
        minPrice: presenter.catalogMinPrice,
        maxPrice: presenter.catalogMaxPrice,
      );

      expect(presenter.filteredProducts.map((product) => product.id), ['2']);
      expect(presenter.selectedProductName, 'Giày bóng đá');
    });

    test('clears all color and price filters', () async {
      final presenter = CategoryProductsPresenter(
        productRepository: _FakeProductRepository(_products),
        categoryId: '',
      );
      await presenter.loadProducts();
      presenter.applyFilters(
        color: 'Trắng',
        minPrice: 600000,
        maxPrice: 2000000,
      );

      presenter.clearFilters();

      expect(presenter.selectedProductId, isEmpty);
      expect(presenter.selectedColor, isEmpty);
      expect(presenter.filteredProducts, hasLength(3));
      expect(presenter.hasActiveFilters, isFalse);
    });
  });
}

const _products = [
  ProductSummaryModel(
    id: '1',
    name: 'Giày chạy bộ',
    category: 'Giày thể thao',
    price: 1200000,
    colors: ['Đen', 'Trắng'],
  ),
  ProductSummaryModel(
    id: '2',
    name: 'Giày bóng đá',
    category: 'Giày thể thao',
    price: 2200000,
    colors: ['Đen'],
  ),
  ProductSummaryModel(
    id: '3',
    name: 'Tất thể thao',
    category: 'Phụ kiện',
    price: 450000,
    colors: ['Trắng'],
  ),
];

class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.products);

  final List<ProductSummaryModel> products;
  String? requestedCategoryId;

  @override
  Future<List<ProductSummaryModel>> getRecommendedProducts({
    String? categoryId,
    String? brandId,
    String? sportId,
  }) async {
    requestedCategoryId = categoryId;
    return products;
  }

  @override
  Future<ProductDetailModel> getProductDetail(String productId) {
    throw UnimplementedError();
  }

  @override
  Future<List<BrandModel>> getPublicBrands() async => const [];
}
