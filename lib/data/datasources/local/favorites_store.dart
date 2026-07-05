import 'dart:convert';

import 'package:hive/hive.dart';

import '../../models/product_model.dart';

abstract interface class FavoritesStore {
  List<ProductModel> read();

  Future<void> put(ProductModel product);

  Future<void> remove(int id);
}

/// Full snapshots, not ids, so favorites work offline.
class HiveFavoritesStore implements FavoritesStore {
  HiveFavoritesStore(this._box);

  final Box<dynamic> _box;

  @override
  List<ProductModel> read() {
    final products = <ProductModel>[];
    for (final raw in _box.values) {
      try {
        products.add(
          ProductModel.fromJson(
            jsonDecode(raw as String) as Map<String, dynamic>,
          ),
        );
      } on Exception {
        // skip anything that no longer parses
      }
    }
    return products;
  }

  @override
  Future<void> put(ProductModel product) =>
      _box.put('${product.id}', jsonEncode(product.toJson()));

  @override
  Future<void> remove(int id) => _box.delete('$id');
}
