import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plexus/core/errors/app_exception.dart';
import 'package:plexus/data/datasources/local/product_cache.dart';
import 'package:plexus/data/datasources/remote/product_api.dart';
import 'package:plexus/data/models/product_model.dart';
import 'package:plexus/data/repositories/product_repository_impl.dart';

class MockProductApi extends Mock implements ProductApi {}

class InMemoryProductCache implements ProductCache {
  List<ProductModel> stored = [];

  @override
  List<ProductModel> read() => stored;

  @override
  Future<void> save(List<ProductModel> products) async => stored = products;
}

ProductModel buildProduct(int id, {String category = 'electronics'}) {
  return ProductModel(
    id: id,
    title: 'Product $id',
    price: 9.99,
    description: 'A test product',
    category: category,
    image: 'https://example.com/$id.png',
    rating: const RatingModel(rate: 4.2, count: 120),
  );
}

void main() {
  late MockProductApi api;
  late InMemoryProductCache cache;
  late ProductRepositoryImpl repository;

  setUp(() {
    api = MockProductApi();
    cache = InMemoryProductCache();
    repository = ProductRepositoryImpl(api: api, cache: cache);
  });

  group('fetchProducts', () {
    test('returns remote items and refreshes the cache', () async {
      when(
        () => api.fetchAll(),
      ).thenAnswer((_) async => [buildProduct(1), buildProduct(2)]);

      final result = await repository.fetchProducts();

      expect(result.fromCache, isFalse);
      expect(result.items.map((p) => p.id), [1, 2]);
      expect(cache.stored, hasLength(2));
    });

    test('serves cached items when the network is down', () async {
      cache.stored = [buildProduct(1)];
      when(() => api.fetchAll()).thenThrow(const NetworkException());

      final result = await repository.fetchProducts();

      expect(result.fromCache, isTrue);
      expect(result.items.single.id, 1);
    });

    test('rethrows when offline with an empty cache', () async {
      when(() => api.fetchAll()).thenThrow(const NetworkException());

      expect(repository.fetchProducts(), throwsA(isA<NetworkException>()));
    });
  });

  group('fetchProduct', () {
    test('falls back to the cached copy when the request fails', () async {
      cache.stored = [buildProduct(7)];
      when(() => api.fetchById(7)).thenThrow(const NetworkException());

      final product = await repository.fetchProduct(7);

      expect(product.id, 7);
    });

    test('rethrows when the product is not cached either', () async {
      when(() => api.fetchById(7)).thenThrow(const ApiException(404));

      expect(repository.fetchProduct(7), throwsA(isA<ApiException>()));
    });
  });

  group('fetchCategories', () {
    test('derives distinct categories from cache when offline', () async {
      cache.stored = [
        buildProduct(1, category: 'electronics'),
        buildProduct(2, category: 'jewelery'),
        buildProduct(3, category: 'electronics'),
      ];
      when(() => api.fetchCategories()).thenThrow(const NetworkException());

      final categories = await repository.fetchCategories();

      expect(categories, ['electronics', 'jewelery']);
    });
  });
}
