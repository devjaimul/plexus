import 'dart:convert';

import 'package:hive/hive.dart';

import '../../models/product_model.dart';

abstract interface class ProductCache {
  List<ProductModel> read();

  Future<void> save(List<ProductModel> products);
}

/// One JSON string for the whole catalog, it's only ~20 items.
class HiveProductCache implements ProductCache {
  HiveProductCache(this._box);

  static const _key = 'products';

  final Box<dynamic> _box;

  @override
  List<ProductModel> read() {
    final raw = _box.get(_key) as String?;
    if (raw == null) return const [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception {
      // corrupt cache = empty cache
      return const [];
    }
  }

  @override
  Future<void> save(List<ProductModel> products) =>
      _box.put(_key, jsonEncode(products.map((p) => p.toJson()).toList()));
}
