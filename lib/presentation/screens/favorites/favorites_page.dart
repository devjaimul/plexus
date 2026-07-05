import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/context_extensions.dart';
import '../../providers/favorites_providers.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/product_card.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final favorites = ref.watch(favoritesProvider).values.toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabFavorites)),
      body: favorites.isEmpty
          ? EmptyView(
              icon: Icons.favorite_outline,
              title: l10n.favoritesEmptyTitle,
              message: l10n.favoritesEmptyMessage,
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: productGridDelegate,
              itemCount: favorites.length,
              itemBuilder: (context, index) => FadeSlideIn(
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: 25 * (index % 8)),
                offset: const Offset(0, 0.08),
                child: ProductCard(product: favorites[index]),
              ),
            ),
    );
  }
}
