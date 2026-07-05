import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../data/datasources/local/favorites_store.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';

final favoritesStoreProvider = Provider<FavoritesStore>((ref) {
  return HiveFavoritesStore(Hive.box<dynamic>(AppConstants.favoritesBox));
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(ref.watch(favoritesStoreProvider));
});

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Map<int, Product>>(
      FavoritesNotifier.new,
    );

/// Keyed by product id. State first, disk write after.
class FavoritesNotifier extends Notifier<Map<int, Product>> {
  @override
  Map<int, Product> build() => ref.read(favoritesRepositoryProvider).load();

  Future<void> toggle(Product product) async {
    final repository = ref.read(favoritesRepositoryProvider);

    if (state.containsKey(product.id)) {
      state = {...state}..remove(product.id);
      await repository.remove(product.id);
    } else {
      state = {...state, product.id: product};
      await repository.save(product);
    }
  }
}

final isFavoriteProvider = Provider.family<bool, int>((ref, id) {
  return ref.watch(favoritesProvider.select((m) => m.containsKey(id)));
});
