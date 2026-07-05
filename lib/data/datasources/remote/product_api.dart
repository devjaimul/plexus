import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../models/product_model.dart';

class ProductApi {
  ProductApi(this._client);

  final ApiClient _client;

  Future<List<ProductModel>> fetchAll() async {
    final data = await _client.get('/products');
    return (data as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> fetchById(int id) async {
    final data = await _client.get('/products/$id');
    // fakestoreapi answers 200 with an empty body for unknown ids.
    if (data is! Map<String, dynamic>) {
      throw const ApiException(404, 'Product not found');
    }
    return ProductModel.fromJson(data);
  }

  Future<List<String>> fetchCategories() async {
    final data = await _client.get('/products/categories');
    return (data as List<dynamic>).map((e) => e as String).toList();
  }
}
