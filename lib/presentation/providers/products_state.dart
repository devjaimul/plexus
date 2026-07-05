import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product.dart';

part 'products_state.freezed.dart';

enum ProductSort { featured, priceAsc, priceDesc, rating }

@freezed
abstract class ProductsState with _$ProductsState {
  const factory ProductsState({
    required List<Product> all,
    required bool fromCache,
    required int visible,
    @Default('') String query,
    String? category,
    @Default(ProductSort.featured) ProductSort sort,
  }) = _ProductsState;

  const ProductsState._();

  List<Product> get filtered {
    var result = all;

    if (category case final selected?) {
      result = result.where((p) => p.category == selected).toList();
    }

    final term = query.trim().toLowerCase();
    if (term.isNotEmpty) {
      result = result
          .where(
            (p) =>
                p.title.toLowerCase().contains(term) ||
                p.category.toLowerCase().contains(term),
          )
          .toList();
    }

    return switch (sort) {
      ProductSort.featured => result,
      ProductSort.priceAsc => [
        ...result,
      ]..sort((a, b) => a.price.compareTo(b.price)),
      ProductSort.priceDesc => [
        ...result,
      ]..sort((a, b) => b.price.compareTo(a.price)),
      ProductSort.rating => [
        ...result,
      ]..sort((a, b) => b.rating.rate.compareTo(a.rating.rate)),
    };
  }

  List<Product> get page => filtered.take(visible).toList();

  bool get hasMore => visible < filtered.length;
}
