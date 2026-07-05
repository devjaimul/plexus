import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/auth_session.dart';
import '../../providers/auth_providers.dart';
import '../../providers/favorites_providers.dart';
import '../../providers/locale_provider.dart';
import '../../providers/product_providers.dart';
import '../../providers/products_state.dart';
import '../../providers/theme_provider.dart';
import '../../utils/error_messages.dart';
import '../../widgets/error_view.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shimmer_placeholders.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    ref.invalidate(categoriesProvider);
    try {
      await ref.read(productsProvider.notifier).refresh();
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(e, l10n))));
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(authSessionProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);
    final favoritesCount = ref.watch(favoritesProvider.select((m) => m.length));

    // api returns names lowercase
    final name = switch (ref.watch(authSessionProvider).value) {
      SignedIn(:final username, :final profile) =>
        profile != null ? Formatters.titleCase(profile.firstName) : username,
      _ => '',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          const _LanguageMenuButton(),
          const _ThemeMenuButton(),
          IconButton(
            tooltip: l10n.logout,
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: products.when(
        loading: () => const DashboardShimmer(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(productsProvider),
        ),
        data: (state) {
          final topRated = [...state.all]
            ..sort((a, b) => b.rating.rate.compareTo(a.rating.rate));

          return RefreshIndicator(
            onRefresh: () => _refresh(context, ref),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                FadeSlideIn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardGreeting(name),
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.dashboardSubtitle,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.inventory_2_outlined,
                          value: '${state.all.length}',
                          label: l10n.statProducts,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.category_outlined,
                          value: '${categories.value?.length ?? '-'}',
                          label: l10n.statCategories,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.favorite_outline,
                          value: '$favoritesCount',
                          label: l10n.statFavorites,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.categoriesSection,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      categories.when(
                        loading: () => const SizedBox(height: 40),
                        error: (_, _) => const SizedBox.shrink(),
                        data: (list) => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final category in list)
                              ActionChip(
                                label: Text(Formatters.titleCase(category)),
                                onPressed: () {
                                  ref
                                      .read(productsProvider.notifier)
                                      .setCategory(category);
                                  context.go('/products');
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.topRatedSection,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(productsProvider.notifier)
                                  .setSort(ProductSort.rating);
                              context.go('/products');
                            },
                            child: Text(l10n.seeAll),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 250,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: topRated.length > 6 ? 6 : topRated.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) => SizedBox(
                            width: 165,
                            child: ProductCard(product: topRated[index]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LanguageMenuButton extends ConsumerWidget {
  const _LanguageMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return PopupMenuButton<String>(
      tooltip: context.l10n.language,
      icon: const Icon(Icons.translate_outlined),
      onSelected: (code) => ref
          .read(localeProvider.notifier)
          .set(code == 'system' ? null : Locale(code)),
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: 'system',
          checked: locale == null,
          child: Text(context.l10n.languageSystem),
        ),
        // language names stay in their own script on purpose
        CheckedPopupMenuItem(
          value: 'en',
          checked: locale?.languageCode == 'en',
          child: const Text('English'),
        ),
        CheckedPopupMenuItem(
          value: 'bn',
          checked: locale?.languageCode == 'bn',
          child: const Text('বাংলা'),
        ),
        CheckedPopupMenuItem(
          value: 'ar',
          checked: locale?.languageCode == 'ar',
          child: const Text('العربية'),
        ),
      ],
    );
  }
}

class _ThemeMenuButton extends ConsumerWidget {
  const _ThemeMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(themeModeProvider);

    return PopupMenuButton<ThemeMode>(
      tooltip: l10n.theme,
      icon: Icon(switch (mode) {
        ThemeMode.system => Icons.brightness_auto_outlined,
        ThemeMode.light => Icons.light_mode_outlined,
        ThemeMode.dark => Icons.dark_mode_outlined,
      }),
      onSelected: ref.read(themeModeProvider.notifier).set,
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: ThemeMode.system,
          checked: mode == ThemeMode.system,
          child: Text(l10n.themeSystem),
        ),
        CheckedPopupMenuItem(
          value: ThemeMode.light,
          checked: mode == ThemeMode.light,
          child: Text(l10n.themeLight),
        ),
        CheckedPopupMenuItem(
          value: ThemeMode.dark,
          checked: mode == ThemeMode.dark,
          child: Text(l10n.themeDark),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: colors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
