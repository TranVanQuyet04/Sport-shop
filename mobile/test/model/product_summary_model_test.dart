import 'package:flutter_test/flutter_test.dart';
import 'package:sportswear_shop_mobile/model/customer/product_summary_model.dart';

void main() {
  test('parses variant colors from the backend summary response', () {
    final product = ProductSummaryModel.fromJson(const {
      'id': 12,
      'productName': 'Giày chạy bộ',
      'categoryName': 'Giày thể thao',
      'price': 1250000,
      'colors': ['Đen', 'Trắng'],
    });

    expect(product.colors, ['Đen', 'Trắng']);
    expect(product.price, 1250000);
  });
}
