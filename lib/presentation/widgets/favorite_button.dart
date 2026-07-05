import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/context_extensions.dart';
import '../../domain/entities/product.dart';
import '../providers/favorites_providers.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(product.id));
    final colors = context.colorScheme;

    return IconButton(
      tooltip: isFavorite
          ? context.l10n.removeFromFavorites
          : context.l10n.addToFavorites,
      style: IconButton.styleFrom(
        backgroundColor: colors.surface.withValues(alpha: 0.85),
        visualDensity: VisualDensity.compact,
      ),
      iconSize: 18,
      onPressed: () => ref.read(favoritesProvider.notifier).toggle(product),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFavorite),
          color: isFavorite ? Colors.redAccent : colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
