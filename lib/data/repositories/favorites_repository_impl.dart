import '../../domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/local/favorites_store.dart';
import '../models/product_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._store);

  final FavoritesStore _store;

  @override
  Map<int, Product> load() => {
    for (final model in _store.read()) model.id: model.toEntity(),
  };

  @override
  Future<void> save(Product product) =>
      _store.put(ProductModel.fromEntity(product));

  @override
  Future<void> remove(int id) => _store.remove(id);
}
