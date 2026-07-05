import '../entities/product.dart';

abstract interface class ProductRepository {
  /// Remote first, cache fallback with fromCache set.
  Future<({List<Product> items, bool fromCache})> fetchProducts();

  Future<Product> fetchProduct(int id);

  Future<List<String>> fetchCategories();
}
