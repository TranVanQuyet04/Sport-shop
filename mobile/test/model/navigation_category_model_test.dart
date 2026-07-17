import 'package:flutter_test/flutter_test.dart';
import 'package:sportswear_shop_mobile/model/common/backend_models.dart';

void main() {
  group('NavigationCategoryModel.treeFromFlatJson', () {
    test('builds the backend parent-child category hierarchy', () {
      final categories = NavigationCategoryModel.treeFromFlatJson(const [
        {'id': 1, 'categoryName': 'Quần áo thể thao', 'parentId': null},
        {'id': 2, 'categoryName': 'Áo chạy bộ', 'parentId': 1},
        {'id': 3, 'categoryName': 'Quần short', 'parentId': 1},
        {'id': 5, 'categoryName': 'Giày thể thao', 'parentId': null},
      ]);

      expect(categories.map((category) => category.id), ['1', '5']);
      expect(categories.first.children.map((category) => category.id), [
        '2',
        '3',
      ]);
      expect(categories.first.children.first.name, 'Áo chạy bộ');
    });

    test('keeps an orphan category visible as a root item', () {
      final categories = NavigationCategoryModel.treeFromFlatJson(const [
        {'id': 10, 'categoryName': 'Phụ kiện', 'parentId': 999},
      ]);

      expect(categories, hasLength(1));
      expect(categories.single.name, 'Phụ kiện');
    });

    test('ignores records without an id or display name', () {
      final categories = NavigationCategoryModel.treeFromFlatJson(const [
        {'id': 1, 'categoryName': ''},
        {'categoryName': 'Thiếu mã'},
        {'id': 2, 'categoryName': 'Hợp lệ'},
      ]);

      expect(categories, hasLength(1));
      expect(categories.single.id, '2');
    });
  });
}
