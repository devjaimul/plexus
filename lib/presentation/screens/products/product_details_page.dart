import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/product.dart';
import '../../providers/favorites_providers.dart';
import '../../providers/product_providers.dart';
import '../../widgets/error_view.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/shimmer_placeholders.dart';

class ProductDetailsPage extends ConsumerWidget {
  const ProductDetailsPage({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(productDetailsProvider(productId));

    return Scaffold(
      appBar: AppBar(),
      body: details.when(
        loading: () => const DetailsShimmer(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(productDetailsProvider(productId)),
        ),
        data: (product) => LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 720) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _ProductImage(product: product),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                      child: FadeSlideIn(child: _ProductInfo(product: product)),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ProductImage(product: product),
                const SizedBox(height: 20),
                FadeSlideIn(child: _ProductInfo(product: product)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: AspectRatio(
        aspectRatio: 1,
        child: Hero(
          tag: 'product-${product.id}',
          child: CachedNetworkImage(
            imageUrl: product.imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const SizedBox(),
            errorWidget: (context, url, error) => const Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Colors.black26,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductInfo extends ConsumerWidget {
  const _ProductInfo({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colorScheme;
    final isFavorite = ref.watch(isFavoriteProvider(product.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Chip(
          label: Text(Formatters.titleCase(product.category)),
          labelStyle: context.textTheme.labelSmall,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(height: 12),
        Text(
          product.title,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              product.rating.rate.toStringAsFixed(1),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              l10n.reviewsCount(product.rating.count),
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          Formatters.price(product.price),
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.descriptionSection,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.tonalIcon(
            onPressed: () =>
                ref.read(favoritesProvider.notifier).toggle(product),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                child: child,
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isFavorite),
                color: isFavorite ? Colors.redAccent : null,
              ),
            ),
            label: Text(
              isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
            ),
          ),
        ),
      ],
    );
  }
}
