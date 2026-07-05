import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../data/datasources/local/product_cache.dart';
import '../../data/datasources/remote/product_api.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'app_providers.dart';
import 'products_state.dart';

final productApiProvider = Provider<ProductApi>((ref) {
  return ProductApi(ref.watch(apiClientProvider));
});

final productCacheProvider = Provider<ProductCache>((ref) {
  return HiveProductCache(Hive.box<dynamic>(AppConstants.productCacheBox));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    api: ref.watch(productApiProvider),
    cache: ref.watch(productCacheProvider),
  );
});

final categoriesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(productRepositoryProvider).fetchCategories();
});

final productDetailsProvider = FutureProvider.autoDispose.family<Product, int>((
  ref,
  id,
) {
  return ref.watch(productRepositoryProvider).fetchProduct(id);
});

final productsProvider = AsyncNotifierProvider<ProductsNotifier, ProductsState>(
  ProductsNotifier.new,
);

class ProductsNotifier extends AsyncNotifier<ProductsState> {
  @override
  Future<ProductsState> build() async {
    final result = await ref.read(productRepositoryProvider).fetchProducts();
    return ProductsState(
      all: result.items,
      fromCache: result.fromCache,
      visible: AppConstants.productsPageSize,
    );
  }

  /// Returns true when it had to serve cached data.
  Future<bool> refresh() async {
    final result = await ref.read(productRepositoryProvider).fetchProducts();
    final current = state.value;
    state = AsyncData(
      current == null
          ? ProductsState(
              all: result.items,
              fromCache: result.fromCache,
              visible: AppConstants.productsPageSize,
            )
          : current.copyWith(all: result.items, fromCache: result.fromCache),
    );
    return result.fromCache;
  }

  void setQuery(String query) => _update(
    (s) => s.copyWith(query: query, visible: AppConstants.productsPageSize),
  );

  void setCategory(String? category) => _update(
    (s) =>
        s.copyWith(category: category, visible: AppConstants.productsPageSize),
  );

  void setSort(ProductSort sort) => _update(
    (s) => s.copyWith(sort: sort, visible: AppConstants.productsPageSize),
  );

  void loadMore() {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    state = AsyncData(
      current.copyWith(
        visible: current.visible + AppConstants.productsPageSize,
      ),
    );
  }

  void _update(ProductsState Function(ProductsState) change) {
    final current = state.value;
    if (current != null) state = AsyncData(change(current));
  }
}
