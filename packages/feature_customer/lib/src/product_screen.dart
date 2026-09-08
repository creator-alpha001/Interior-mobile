/// One product, and one package.
///
/// The web's `/product/[slug]` and `/packages/[slug]`, neither of which had a
/// mobile equivalent — `getProduct` and `getPackage` were unreachable.
///
/// **Every price on these screens names its city.** `effectivePrice` is
/// computed per city, so a figure shown without one is a number the customer
/// cannot act on and will hold us to anyway. The web says so on the page; this
/// says it beside the figure, where a phone reader will actually see it.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'catalogue.dart';
import 'providers.dart';

final productProvider = FutureProvider.family<ProductView, String>((ref, slug) {
  final city = ref.watch(catalogueFiltersProvider).cityId;
  return ref
      .watch(customerApiProvider)
      .public
      .getProduct(slug: slug, city: city)
      .orThrow();
});

final relatedProductsProvider =
    FutureProvider.family<List<ProductView>, String>((ref, id) {
      final city = ref.watch(catalogueFiltersProvider).cityId;
      return ref
          .watch(customerApiProvider)
          .public
          .listRelatedProducts(id: id, city: city)
          .orThrow();
    });

/// How a price is quoted. A unit is a word, so it translates.
String priceUnitLabel(BuildContext context, PriceUnit unit) => switch (unit) {
  PriceUnit.perPiece => context.t('per piece'),
  PriceUnit.perSqft => context.t('per sq.ft'),
  PriceUnit.perRunningFt => context.t('per running ft'),
  PriceUnit.perKg => context.t('per kg'),
  PriceUnit.perRoom => context.t('per room'),
  PriceUnit.perProject => context.t('per project'),
  PriceUnit.$unknown => '',
};

class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key, required this.slug, this.onStart});

  final String slug;

  /// Opens the requirement flow. This is the only thing to *do* with a
  /// product: there is no cart and no checkout, because the platform does not
  /// sell anything — it introduces somebody who will quote for it.
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productProvider(slug));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: AsyncView(
          value: product,
          onRetry: () => ref.invalidate(productProvider(slug)),
          data: (view) => _Detail(view: view, onStart: onStart),
        ),
      ),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.view, this.onStart});

  final ProductView view;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = view.product;
    final cityId = ref.watch(catalogueFiltersProvider).cityId;
    final cities = ref.watch(citiesProvider);

    final cityName = cities.maybeWhen(
      data: (list) {
        for (final city in list) {
          if (city.id == cityId) return city.name;
        }
        return null;
      },
      orElse: () => null,
    );

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: AanganMedia(
            src: product.media.isEmpty
                ? 'ph:default:x'
                : product.media.first.url,
            alt: product.name,
            label: product.name,
            rounded: false,
          ),
        ),

        // The rest of the gallery, when there is one.
        if (product.media.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.gutter,
              Space.sm,
              Space.gutter,
              0,
            ),
            child: MediaStrip(
              items: [
                for (final asset in product.media.skip(1))
                  MediaItem(
                    url: asset.url,
                    caption: asset.caption ?? product.name,
                  ),
              ],
            ),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Space.md),
              Text(
                view.domain.name.toUpperCase(),
                style: context.text.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.xxs),
              Text(product.name, style: context.text.displayLarge),
              const SizedBox(height: Space.sm),
              Text(
                product.shortDescription,
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: Space.md),
              AanganCard(
                padding: const EdgeInsets.all(Space.cardPaddingWide),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('Starting at'),
                      style: context.text.labelMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Space.xxs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        MoneyText(Rupees(view.effectivePrice).formatted),
                        const SizedBox(width: Space.xxs),
                        Text(
                          priceUnitLabel(context, product.priceUnit),
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    /// The city the figure belongs to, beside the figure.
                    ///
                    /// Without this the price reads as arbitrary — and it
                    /// genuinely does change with the city, so a customer who
                    /// sees a different number tomorrow is right to ask.
                    const SizedBox(height: Space.xxs),
                    Text(
                      cityName == null
                          ? context.t(
                              'Prices vary by city. Choose one in the filter '
                              'to see yours.',
                            )
                          : context.t('In {city}', {'city': cityName}),
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),

                    if (product.isCustomisable) ...[
                      const SizedBox(height: Space.xs),
                      StatusPill(
                        context.t('Made to your measurements'),
                        tone: StatusTone.neutral,
                      ),
                    ],
                  ],
                ),
              ),

              if (product.description.isNotEmpty) ...[
                SectionHead(
                  context.t('About this'),
                  eyebrow: context.t('Detail'),
                ),
                Text(product.description, style: context.text.bodyMedium),
              ],

              if (product.specs.isNotEmpty) ...[
                SectionHead(
                  context.t('Specification'),
                  eyebrow: context.t('As supplied'),
                ),
                for (final spec in product.specs.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xxs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 130,
                          child: Text(
                            spec.key,
                            style: context.text.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            spec.value,
                            style: context.text.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],

              const SizedBox(height: Space.xs),
              Text(
                context.l10n.plural(
                  product.leadTimeDays,
                  'Usually about {n} day once work starts',
                  'Usually about {n} days once work starts',
                ),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),

              if (onStart != null) ...[
                const SizedBox(height: Space.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onStart,
                    child: Text(context.t('Get quotes for this')),
                  ),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  /// No cart, and the copy has to explain why rather than
                  /// leaving somebody hunting for one. The platform sells
                  /// nothing; it introduces three people who will quote.
                  context.t(
                    'Nothing is bought here. We take this to three verified '
                    'professionals and bring back their prices.',
                  ),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],

              _Related(id: product.id),
              const SizedBox(height: Space.xxxl),
            ],
          ),
        ),
      ],
    );
  }
}

class _Related extends ConsumerWidget {
  const _Related({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final related = ref.watch(relatedProductsProvider(id));

    // Absent rather than broken when it fails — an error box under a product
    // somebody is reading about is worse than no section.
    return related.maybeWhen(
      data: (list) => list.isEmpty
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHead(
                  context.t('Similar work'),
                  eyebrow: context.t('Also in this trade'),
                ),
                SizedBox(
                  height: 290,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: Space.sm),
                    itemBuilder: (context, i) =>
                        SizedBox(width: 200, child: ProductCard(view: list[i])),
                  ),
                ),
              ],
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
