import '../entities/product.dart';

abstract interface class FavoritesRepository {
  Map<int, Product> load();

  Future<void> save(Product product);

  Future<void> remove(int id);
}
