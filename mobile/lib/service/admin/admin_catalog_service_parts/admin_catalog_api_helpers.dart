part of '../admin_catalog_service.dart';

List<Map<String, dynamic>> _parseList(Map<String, dynamic> json) {
  final rawItems = json['result'] ?? json['data'] ?? json['content'] ?? json;
  if (rawItems is Map && rawItems['brands'] is List) {
    return (rawItems['brands'] as List)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  if (rawItems is! List) {
    return const [];
  }
  return rawItems
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Map<String, dynamic> _parseObject(Map<String, dynamic> json) {
  final rawItem = json['result'] ?? json['data'] ?? json;
  if (rawItem is Map) {
    return Map<String, dynamic>.from(rawItem);
  }
  return const {};
}

int? _nullableInt(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return int.tryParse(value.trim());
}

List<int> _parseVariantIds(List<String> variantIds) {
  return variantIds
      .map((id) => int.tryParse(id.trim()))
      .whereType<int>()
      .toSet()
      .toList(growable: false);
}

String _slugify(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

Map<String, dynamic> _productPayload({
  required String name,
  required String description,
  required String categoryName,
  required String brandName,
  required String sportName,
  required List<Map<String, dynamic>> variants,
}) {
  return {
    'productName': name,
    'description': description,
    'categoryName': categoryName,
    'brandName': brandName,
    'sportName': sportName,
    'variants': variants,
  };
}
