import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required int id,
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
    required RatingModel rating,
  }) = _ProductModel;

  const ProductModel._();

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  factory ProductModel.fromEntity(Product product) => ProductModel(
    id: product.id,
    title: product.title,
    price: product.price,
    description: product.description,
    category: product.category,
    image: product.imageUrl,
    rating: RatingModel(rate: product.rating.rate, count: product.rating.count),
  );

  Product toEntity() => Product(
    id: id,
    title: title,
    price: price,
    description: description,
    category: category,
    imageUrl: image,
    rating: ProductRating(rate: rating.rate, count: rating.count),
  );
}

@freezed
abstract class RatingModel with _$RatingModel {
  const factory RatingModel({required double rate, required int count}) =
      _RatingModel;

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);
}
