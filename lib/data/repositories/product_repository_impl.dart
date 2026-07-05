import '../../core/errors/app_exception.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_cache.dart';
import '../datasources/remote/product_api.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required ProductApi api, required ProductCache cache})
    : _api = api,
      _cache = cache;

  final ProductApi _api;
  final ProductCache _cache;

  @override
  Future<({List<Product> items, bool fromCache})> fetchProducts() async {
    try {
      final models = await _api.fetchAll();
      await _cache.save(models);
      return (
        items: models.map((m) => m.toEntity()).toList(),
        fromCache: false,
      );
    } on AppException {
      // stale data beats an error screen
      final cached = _cache.read();
      if (cached.isEmpty) rethrow;
      return (items: cached.map((m) => m.toEntity()).toList(), fromCache: true);
    }
  }

  @override
  Future<Product> fetchProduct(int id) async {
    try {
      final model = await _api.fetchById(id);
      return model.toEntity();
    } on AppException {
      for (final model in _cache.read()) {
        if (model.id == id) return model.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<List<String>> fetchCategories() async {
    try {
      return await _api.fetchCategories();
    } on AppException {
      final cached = _cache.read();
      if (cached.isEmpty) rethrow;
      return cached.map((m) => m.category).toSet().toList();
    }
  }
}
