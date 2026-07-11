part of '../admin_add_product_page.dart';

extension _AdminAddProductStateHelpers on _AdminAddProductPageState {
  Map<String, dynamic> _variantPayload() {
    final images = _imageController.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return {
      'size': _sizeController.text.trim(),
      'color': _colorController.text.trim(),
      'price': int.tryParse(_priceController.text.trim()) ?? 0,
      'stockQuantity': int.tryParse(_stockController.text.trim()) ?? 0,
      'sku': _skuController.text.trim(),
      'imageUrls': images,
    };
  }

  void _closePage() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.adminProducts);
  }
}
