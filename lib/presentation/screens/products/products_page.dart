import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/product_providers.dart';
import '../../providers/products_state.dart';
import '../../utils/error_messages.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shimmer_placeholders.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref.read(productsProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final fromCache = await ref.read(productsProvider.notifier).refresh();
      if (fromCache) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.cachedDataNotice)));
      }
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(e, l10n))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabProducts),
        actions: const [_SortMenuButton()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: _searchController,
                  builder: (context, value, _) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(productsProvider.notifier).setQuery('');
                          },
                        ),
                ),
              ),
              onChanged: (value) => _debouncer.run(
                () => ref.read(productsProvider.notifier).setQuery(value),
              ),
            ),
          ),
          const _CategoryFilter(),
          if (state.value?.fromCache ?? false)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 14,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.cachedDataNotice,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: state.when(
                loading: () =>
                    const ProductGridShimmer(key: ValueKey('loading')),
                error: (error, _) => ErrorView(
                  key: const ValueKey('error'),
                  error: error,
                  onRetry: () => ref.invalidate(productsProvider),
                ),
                data: (data) => RefreshIndicator(
                  key: const ValueKey('data'),
                  onRefresh: _refresh,
                  child: data.page.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 60),
                            EmptyView(
                              icon: Icons.search_off,
                              title: l10n.noResultsTitle,
                              message: l10n.noResultsMessage,
                            ),
                          ],
                        )
                      : CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                12,
                              ),
                              sliver: SliverGrid.builder(
                                gridDelegate: productGridDelegate,
                                itemCount: data.page.length,
                                itemBuilder: (context, index) => FadeSlideIn(
                                  duration: const Duration(milliseconds: 300),
                                  delay: Duration(
                                    milliseconds: 25 * (index % 8),
                                  ),
                                  offset: const Offset(0, 0.08),
                                  child: ProductCard(product: data.page[index]),
                                ),
                              ),
                            ),
                            if (data.hasMore)
                              const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 24),
                                  child: Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends ConsumerWidget {
  const _CategoryFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final categories = ref.watch(categoriesProvider).value ?? const <String>[];
    final selected = ref.watch(
      productsProvider.select((s) => s.value?.category),
    );
    final notifier = ref.read(productsProvider.notifier);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: Text(l10n.filterAll),
            selected: selected == null,
            showCheckmark: false,
            onSelected: (_) => notifier.setCategory(null),
          ),
          for (final category in categories) ...[
            const SizedBox(width: 8),
            FilterChip(
              label: Text(Formatters.titleCase(category)),
              selected: selected == category,
              onSelected: (_) =>
                  notifier.setCategory(selected == category ? null : category),
            ),
          ],
        ],
      ),
    );
  }
}

class _SortMenuButton extends ConsumerWidget {
  const _SortMenuButton();

  String _label(BuildContext context, ProductSort sort) => switch (sort) {
    ProductSort.featured => context.l10n.sortFeatured,
    ProductSort.priceAsc => context.l10n.sortPriceAsc,
    ProductSort.priceDesc => context.l10n.sortPriceDesc,
    ProductSort.rating => context.l10n.sortRating,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(productsProvider.select((s) => s.value?.sort)) ??
        ProductSort.featured;

    return PopupMenuButton<ProductSort>(
      tooltip: context.l10n.sortTooltip,
      icon: const Icon(Icons.sort),
      onSelected: ref.read(productsProvider.notifier).setSort,
      itemBuilder: (context) => [
        for (final sort in ProductSort.values)
          CheckedPopupMenuItem(
            value: sort,
            checked: sort == current,
            child: Text(_label(context, sort)),
          ),
      ],
    );
  }
}
