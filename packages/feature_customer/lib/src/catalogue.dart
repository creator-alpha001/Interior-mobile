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

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'filter_choices.dart';
import 'product_screen.dart';
import 'providers.dart';

/// What the catalogue is currently showing.
///
/// One object rather than eight providers, because the filters are read
/// together on every fetch and separate providers would make the screen fetch
/// once per filter while somebody sets three of them.
@immutable
class CatalogueFilters {
  const CatalogueFilters({
    this.domainSlug,
    this.categorySlug,
    this.cityId,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.sort = Sort.featured,
  });

  final String? domainSlug;
  final String? categorySlug;
  final String? cityId;
  final String? search;
  final int? minPrice;
  final int? maxPrice;
  final double? minRating;
  final Sort sort;

  CatalogueFilters copyWith({
    Object? domainSlug = _keep,
    Object? categorySlug = _keep,
    Object? cityId = _keep,
    Object? search = _keep,
    Object? minPrice = _keep,
    Object? maxPrice = _keep,
    Object? minRating = _keep,
    Sort? sort,
  }) {
    return CatalogueFilters(
      domainSlug: domainSlug == _keep ? this.domainSlug : domainSlug as String?,
      categorySlug: categorySlug == _keep
          ? this.categorySlug
          : categorySlug as String?,
      cityId: cityId == _keep ? this.cityId : cityId as String?,
      search: search == _keep ? this.search : search as String?,
      minPrice: minPrice == _keep ? this.minPrice : minPrice as int?,
      maxPrice: maxPrice == _keep ? this.maxPrice : maxPrice as int?,
      minRating: minRating == _keep ? this.minRating : minRating as double?,
      sort: sort ?? this.sort,
    );
  }

  /// A sentinel, so `copyWith(categorySlug: null)` can *clear* a filter rather
  /// than being indistinguishable from not passing it. Every filter here is
  /// nullable and every one of them needs clearing.
  static const _keep = Object();

  bool get hasPrice => minPrice != null || maxPrice != null;

  /// A price range counts once, however many of its two ends are set.
  int get activeCount =>
      [categorySlug, cityId, minRating].where((v) => v != null).length +
      (hasPrice ? 1 : 0);

  @override
  bool operator ==(Object other) =>
      other is CatalogueFilters &&
      other.domainSlug == domainSlug &&
      other.categorySlug == categorySlug &&
      other.cityId == cityId &&
      other.search == search &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.minRating == minRating &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    domainSlug,
    categorySlug,
    cityId,
    search,
    minPrice,
    maxPrice,
    minRating,
    sort,
  );
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
        minPrice: f.minPrice,
        maxPrice: f.maxPrice,
        minRating: f.minRating,
        sort: f.sort,
      )
      .orThrow();
});

/// The trade's whole price range, unfiltered, to draw the bands from.
///
/// Bands drawn from the filtered page would shrink every time one was picked,
/// so this follows only the trade and the city — the two things that change
/// what the prices actually are.
final pricePoolProvider = FutureProvider<List<int>>((ref) async {
  final (domain, city) = ref.watch(
    catalogueFiltersProvider.select((f) => (f.domainSlug, f.cityId)),
  );
  final page = await ref
      .watch(customerApiProvider)
      .public
      .listProducts(domain: domain, city: city, limit: 48)
      .orThrow();
  return [for (final view in page.items) view.effectivePrice];
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

/// Opens the catalogue on one trade, or on everything, with its filters fresh.
///
/// The filters live in a provider that outlasts the screen, so arriving from
/// the "Painting" tile after browsing furniture used to show furniture under a
/// "Painting" title. Every way in goes through here and says what it wants.
Future<void> openCatalogue(
  BuildContext context,
  WidgetRef ref, {
  Domain? domain,
}) {
  ref.read(catalogueFiltersProvider.notifier).state = CatalogueFilters(
    domainSlug: domain?.slug,
  );
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          CatalogueScreen(domainSlug: domain?.slug, title: domain?.name),
    ),
  );
}

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

    return InterioBeeCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductScreen(slug: product.slug)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: InterioBeeMedia(
              // A photograph from the trade's own pool, keyed to the piece, so
              // an item with no upload still looks like the thing it is.
              src: product.media.isEmpty
                  ? 'ph:${view.domain.slug}:${product.id}'
                  : product.media.first.url,
              alt: product.name,
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

/// The web's catalogue sidebar, section for section.
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  static const _ratings = <double>[4.5, 4, 3];

  final _min = TextEditingController();
  final _max = TextEditingController();

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  /// Typed bounds win over a band, as on the web: typing is the more specific
  /// answer. Nothing typed leaves whatever band was picked alone.
  void _applyTyped() {
    final min = int.tryParse(_min.text);
    final max = int.tryParse(_max.text);
    if (min == null && max == null) return;
    ref
        .read(catalogueFiltersProvider.notifier)
        .update((f) => f.copyWith(minPrice: min, maxPrice: max));
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(catalogueFiltersProvider);
    final categories = ref.watch(categoriesProvider);
    final cities = ref.watch(citiesProvider);
    final bands = ref
        .watch(pricePoolProvider)
        .maybeWhen(data: priceBands, orElse: () => const <PriceBand>[]);
    final notifier = ref.read(catalogueFiltersProvider.notifier);

    final selectedBand = filters.hasPrice
        ? PriceBand(min: filters.minPrice, max: filters.maxPrice)
        : null;

    return SafeArea(
      child: Padding(
        // Lifts the sheet over the keyboard while a price is being typed.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
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
            /// Not a delivery filter and not a convenience — `effectivePrice`
            /// is computed per city, so this control changes every figure on
            /// the screen behind it, and the price bands below with it.
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

            SectionHead(context.t('Price')),
            FilterChoices<PriceBand>(
              options: [
                (null, context.t('Any price')),
                for (final band in bands) (band, priceBandLabel(context, band)),
              ],
              // A typed range that matches no band leaves "Any" unticked and
              // no band ticked, which is true: the fields below hold it.
              selected: bands.contains(selectedBand) ? selectedBand : null,
              onSelect: (band) {
                _min.clear();
                _max.clear();
                notifier.update(
                  (f) => f.copyWith(minPrice: band?.min, maxPrice: band?.max),
                );
              },
            ),
            const SizedBox(height: Space.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _min,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: context.t('Minimum'),
                      prefixText: '₹ ',
                    ),
                    onSubmitted: (_) => _applyTyped(),
                  ),
                ),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: TextField(
                    controller: _max,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: context.t('Maximum'),
                      prefixText: '₹ ',
                    ),
                    onSubmitted: (_) => _applyTyped(),
                  ),
                ),
              ],
            ),

            SectionHead(context.t('Customer rating')),
            FilterChoices<double>(
              options: [
                (null, context.t('Any rating')),
                for (final r in _ratings)
                  (
                    r,
                    context.t('{rating} ★ and above', {
                      'rating': ratingFloor(r),
                    }),
                  ),
              ],
              selected: filters.minRating,
              onSelect: (r) => notifier.update((f) => f.copyWith(minRating: r)),
            ),

            const SizedBox(height: Space.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  _applyTyped();
                  Navigator.of(context).pop();
                },
                child: Text(context.t('Show results')),
              ),
            ),
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }
}
