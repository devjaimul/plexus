import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required int id,
    required String title,
    required double price,
    required String description,
    required String category,
    required String imageUrl,
    required ProductRating rating,
  }) = _Product;
}

@freezed
abstract class ProductRating with _$ProductRating {
  const factory ProductRating({required double rate, required int count}) =
      _ProductRating;
}
