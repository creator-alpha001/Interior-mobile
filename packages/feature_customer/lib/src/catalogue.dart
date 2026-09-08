/// Browsing the catalogue.
///
/// The web's `/catalogue` and `/catalogue/[domain]`, which had no mobile
/// equivalent at all — the Explore tab went straight to the professionals
/// directory, and `listProducts`, `listCategories`, `getProduct`, `listPackages`
/// and `getPackage` were reachable from nowhere.
///
/// **The city is not a filter like the others.** `effectivePrice` is computed
/// per city, so a price shown without saying which city it is for is a number
/// the customer cannot act on — and worse, one that changes under them when the
/// city does. The selected city is a first-class part of this screen's state and
/// is named on every price.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'product_screen.dart';
import 'providers.dart';

/// What the catalogue is currently showing.
///
/// One object rather than five providers, because the filters are read
/// together on every fetch and separate providers would make the screen fetch
/// five times while somebody sets three of them.
@immutable
class CatalogueFilters {
  const CatalogueFilters({
    this.domainSlug,
    this.categorySlug,
    this.cityId,
    this.search,
    this.maxPrice,
    this.sort = Sort.featured,
  });

  final String? domainSlug;
  final String? categorySlug;
  final String? cityId;
  final String? search;
  final int? maxPrice;
  final Sort sort;

  CatalogueFilters copyWith({
    Object? domainSlug = _keep,
    Object? categorySlug = _keep,
    Object? cityId = _keep,
    Object? search = _keep,
    Object? maxPrice = _keep,
    Sort? sort,
  }) {
    return CatalogueFilters(
      domainSlug: domainSlug == _keep ? this.domainSlug : domainSlug as String?,
      categorySlug: categorySlug == _keep
          ? this.categorySlug
          : categorySlug as String?,
      cityId: cityId == _keep ? this.cityId : cityId as String?,
      search: search == _keep ? this.search : search as String?,
      maxPrice: maxPrice == _keep ? this.maxPrice : maxPrice as int?,
      sort: sort ?? this.sort,
    );
  }

  /// A sentinel, so `copyWith(categorySlug: null)` can *clear* a filter rather
  /// than being indistinguishable from not passing it. Every filter here is
  /// nullable and every one of them needs clearing.
  static const _keep = Object();

  int get activeCount =>
      [categorySlug, cityId, maxPrice].where((v) => v != null).length;

  @override
  bool operator ==(Object other) =>
      other is CatalogueFilters &&
      other.domainSlug == domainSlug &&
      other.categorySlug == categorySlug &&
      other.cityId == cityId &&
      other.search == search &&
      other.maxPrice == maxPrice &&
      other.sort == sort;

  @override
  int get hashCode =>
      Object.hash(domainSlug, categorySlug, cityId, search, maxPrice, sort);
}

final catalogueFiltersProvider = StateProvider<CatalogueFilters>(
  (ref) => const CatalogueFilters(),
);

final productsProvider = FutureProvider<GetProductsResponse>((ref) {
  final f = ref.watch(catalogueFiltersProvider);
  return ref
      .watch(customerApiProvider)
      .public
      .listProducts(
        domain: f.domainSlug,
        category: f.categorySlug,
        city: f.cityId,
        search: f.search,
        maxPrice: f.maxPrice,
        sort: f.sort,
      )
      .orThrow();
});

/// Categories belong to a trade, so they are refetched when the trade changes.
final categoriesProvider = FutureProvider<List<ProductCategory>>((ref) {
  final domain = ref.watch(catalogueFiltersProvider).domainSlug;
  return ref
      .watch(customerApiProvider)
      .public
      .listCategories(domain: domain)
      .orThrow();
});

class CatalogueScreen extends ConsumerWidget {
  const CatalogueScreen({super.key, this.domainSlug, this.title});

  /// Set when arriving from a trade, cleared when browsing everything.
  final String? domainSlug;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final filters = ref.watch(catalogueFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? context.t('Catalogue')),
        actions: [
          IconButton(
            onPressed: () => showCatalogueFilters(context, ref),
            icon: Badge(
              isLabelVisible: filters.activeCount > 0,
              label: Text('${filters.activeCount}'),
              child: const Icon(Icons.tune),
            ),
            tooltip: context.t('Filter'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Sorts(
              selected: filters.sort,
              onSelect: (sort) => ref
                  .read(catalogueFiltersProvider.notifier)
                  .update((f) => f.copyWith(sort: sort)),
            ),
            Expanded(
              child: AsyncView(
                value: products,
                onRetry: () => ref.invalidate(productsProvider),
                data: (page) => page.items.isEmpty
                    ? EmptyState(
                        title: context.t('Nothing matches'),
                        body: context.t(
                          'Try a wider price, or clear a filter. Everything '
                          'here can also be made to order — tell us what you '
                          'need instead.',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => ref.invalidate(productsProvider),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(Space.gutter),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: Space.sm,
                                crossAxisSpacing: Space.sm,
                                // Tall enough for a 4:3 tile, the trade, two
                                // lines of name and a price.
                                childAspectRatio: 0.58,
                              ),
                          itemCount: page.items.length,
                          itemBuilder: (context, i) =>
                              ProductCard(view: page.items[i]),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The four sorts the web offers, in the same order.
class _Sorts extends StatelessWidget {
  const _Sorts({required this.selected, required this.onSelect});

  final Sort selected;
  final ValueChanged<Sort> onSelect;

  /// The four the web offers, in its order.
  static const _order = <Sort>[
    Sort.featured,
    Sort.priceAsc,
    Sort.priceDesc,
    Sort.rating,
  ];

  /// Written as literals at the call site rather than held in a map.
  ///
  /// `context.t(someMap[key])` passes a *value*, which the source scan in
  /// `l10n_test.dart` cannot see — so the strings would ship untranslated with
  /// nothing failing. The estimator's table has the same shape and buys its way
  /// out with a special case in that test; four labels do not justify a second
  /// one.
  static String _label(BuildContext context, Sort sort) => switch (sort) {
    Sort.featured => context.t('Featured'),
    Sort.priceAsc => context.t('Price: low to high'),
    Sort.priceDesc => context.t('Price: high to low'),
    Sort.rating => context.t('Top rated'),
    Sort.$unknown => context.t('Featured'),
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TapTarget.minimum,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
        children: [
          for (final sort in _order) ...[
            ChoiceChip(
              label: Text(_label(context, sort)),
              selected: selected == sort,
              onSelected: (_) => onSelect(sort),
            ),
            const SizedBox(width: Space.xs),
          ],
        ],
      ),
    );
  }
}

/// One product, as the web's `ProductCard` draws it.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.view});

  final ProductView view;

  @override
  Widget build(BuildContext context) {
    final product = view.product;

    return AanganCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductScreen(slug: product.slug)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: AanganMedia(
              src: product.media.isEmpty
                  ? 'ph:default:x'
                  : product.media.first.url,
              alt: product.name,
              // Names the piece on a placeholder tile, so an item with no
              // photograph reads as a designed card rather than a failed image.
              label: product.name,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Space.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  view.domain.name.toUpperCase(),
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Space.xxs),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: Space.xxs),

                /// "Starting at", never a bare figure.
                ///
                /// `effectivePrice` follows the selected city and the product
                /// is customisable, so a number presented as *the* price is one
                /// the customer will hold us to.
                Text(
                  context.t('Starting at'),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  Rupees(view.effectivePrice).formatted,
                  style: context.text.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showCatalogueFilters(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(catalogueFiltersProvider);
    final categories = ref.watch(categoriesProvider);
    final cities = ref.watch(citiesProvider);
    final notifier = ref.read(catalogueFiltersProvider.notifier);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
        children: [
          const SizedBox(height: Space.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.t('Filter'),
                  style: context.text.headlineSmall,
                ),
              ),
              if (filters.activeCount > 0)
                TextButton(
                  onPressed: () {
                    notifier.state = CatalogueFilters(
                      domainSlug: filters.domainSlug,
                      sort: filters.sort,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(context.t('Clear all')),
                ),
            ],
          ),

          SectionHead(
            context.t('Category'),
            eyebrow: context.t('Within this trade'),
          ),
          categories.maybeWhen(
            data: (list) => Wrap(
              spacing: Space.xxs,
              runSpacing: Space.xxs,
              children: [
                for (final category in list)
                  ChoiceChip(
                    label: Text(category.name),
                    selected: filters.categorySlug == category.slug,
                    onSelected: (on) => notifier.update(
                      (f) =>
                          f.copyWith(categorySlug: on ? category.slug : null),
                    ),
                  ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),

          /// The city is here because the *price* depends on it.
          ///
          /// Not a delivery filter and not a convenience — `effectivePrice` is
          /// computed per city, so this control changes every figure on the
          /// screen behind it.
          SectionHead(
            context.t('City'),
            eyebrow: context.t('Prices follow the city'),
          ),
          cities.maybeWhen(
            data: (list) => Wrap(
              spacing: Space.xxs,
              runSpacing: Space.xxs,
              children: [
                for (final city in list)
                  ChoiceChip(
                    label: Text(city.name),
                    selected: filters.cityId == city.id,
                    onSelected: (on) => notifier.update(
                      (f) => f.copyWith(cityId: on ? city.id : null),
                    ),
                  ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),

          const SizedBox(height: Space.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.t('Show results')),
            ),
          ),
          const SizedBox(height: Space.xxxl),
        ],
      ),
    );
  }
}
