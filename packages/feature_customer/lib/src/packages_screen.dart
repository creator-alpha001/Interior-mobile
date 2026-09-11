/// Packages: a fixed scope at a fixed price.
///
/// The web's `/packages` and `/packages/[slug]`, neither of which existed on
/// mobile — `listPackages` and `getPackage` were unreachable.
///
/// **What is *not* included is as important as what is.** A package is a
/// bounded scope, and the whole reason a customer trusts one is that its edges
/// are stated. The web gives inclusions and exclusions equal room and so does
/// this: an exclusion discovered halfway through a job is the complaint that
/// costs a professional their rating.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

final packagesProvider = FutureProvider.family<List<PackageView>, String?>((
  ref,
  domainSlug,
) {
  return ref
      .watch(customerApiProvider)
      .public
      .listPackages(domain: domainSlug)
      .orThrow();
});

final packageProvider = FutureProvider.family<PackageView, String>((ref, slug) {
  return ref.watch(customerApiProvider).public.getPackage(slug: slug).orThrow();
});

class PackagesScreen extends ConsumerWidget {
  const PackagesScreen({super.key, this.domainSlug, this.onStart});

  final String? domainSlug;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packages = ref.watch(packagesProvider(domainSlug));

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Packages'))),
      body: SafeArea(
        child: AsyncView(
          value: packages,
          onRetry: () => ref.invalidate(packagesProvider(domainSlug)),
          data: (list) => list.isEmpty
              ? EmptyState(
                  title: context.t('No packages yet'),
                  body: context.t(
                    'Tell us what you need instead and we will have it quoted '
                    'from scratch.',
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
                  children: [
                    const SizedBox(height: Space.sm),
                    Text(
                      context.t(
                        'A fixed scope at a fixed price. Everything a package '
                        'leaves out is listed too, because that is the part '
                        'people find out about halfway through.',
                      ),
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Space.md),
                    for (final view in list) ...[
                      PackageCard(view: view, onStart: onStart),
                      const SizedBox(height: Space.sm),
                    ],
                    const SizedBox(height: Space.xxxl),
                  ],
                ),
        ),
      ),
    );
  }
}

class PackageCard extends StatelessWidget {
  const PackageCard({super.key, required this.view, this.onStart});

  final PackageView view;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final package = view.servicePackage;

    return InterioBeeCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PackageScreen(slug: package.slug, onStart: onStart),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: InterioBeeMedia(
              src: package.media.isEmpty
                  ? 'ph:${view.domain.slug}:${package.id}'
                  : package.media.first.url,
              alt: package.name,
              label: package.name,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Space.cardPaddingWide),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        view.domain.name.toUpperCase(),
                        style: context.text.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (package.badge != null)
                      StatusPill(package.badge!, tone: StatusTone.neutral),
                  ],
                ),
                const SizedBox(height: Space.xxs),
                Text(package.name, style: context.text.headlineSmall),
                const SizedBox(height: Space.xxs),
                Text(
                  package.shortDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Space.sm),
                MoneyText(Rupees(package.price).formatted),
                Text(
                  // The basis is the server's own words — "per sq.ft of carpet
                  // area", "per project" — and carries the price's meaning.
                  package.priceBasis,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PackageScreen extends ConsumerWidget {
  const PackageScreen({super.key, required this.slug, this.onStart});

  final String slug;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final package = ref.watch(packageProvider(slug));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: AsyncView(
          value: package,
          onRetry: () => ref.invalidate(packageProvider(slug)),
          data: (view) => _Detail(view: view, onStart: onStart),
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.view, this.onStart});

  final PackageView view;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final package = view.servicePackage;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: InterioBeeMedia(
            src: package.media.isEmpty
                ? 'ph:${view.domain.slug}:${package.id}'
                : package.media.first.url,
            alt: package.name,
            label: package.name,
            rounded: false,
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
              Text(package.name, style: context.text.displayLarge),
              const SizedBox(height: Space.sm),
              Text(
                package.description.isEmpty
                    ? package.shortDescription
                    : package.description,
                style: context.text.bodyLarge,
              ),

              const SizedBox(height: Space.md),
              InterioBeeCard(
                padding: const EdgeInsets.all(Space.cardPaddingWide),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MoneyText(Rupees(package.price).formatted),
                    Text(
                      package.priceBasis,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      context.l10n.plural(
                        package.durationDays,
                        'About {n} day of work',
                        'About {n} days of work',
                      ),
                      style: context.text.bodyMedium,
                    ),
                  ],
                ),
              ),

              if (view.items.isNotEmpty) ...[
                SectionHead(
                  context.t('What it covers'),
                  eyebrow: context.t('Line by line'),
                ),
                for (final line in view.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xxs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            line.label,
                            style: context.text.bodyMedium,
                          ),
                        ),
                        Text(
                          // A count, not a word — the unit lives in the label.
                          '×${line.quantity}',
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],

              if (package.inclusions.isNotEmpty) ...[
                SectionHead(
                  context.t('Included'),
                  eyebrow: context.t('In the price'),
                ),
                for (final item in package.inclusions)
                  _Bullet(text: item, tone: context.palette.verified),
              ],

              /// Given the same room as the inclusions, deliberately.
              ///
              /// An exclusion discovered halfway through a job is the
              /// complaint that costs a professional their rating, and a
              /// package whose edges are vague is worse than no package.
              if (package.exclusions.isNotEmpty) ...[
                SectionHead(
                  context.t('Not included'),
                  eyebrow: context.t('Quoted separately'),
                ),
                for (final item in package.exclusions)
                  _Bullet(text: item, tone: context.colors.outline),
              ],

              if (onStart != null) ...[
                const SizedBox(height: Space.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onStart,
                    child: Text(context.t('Get quotes for this package')),
                  ),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  context.t(
                    'The package sets the scope. Professionals still quote '
                    'against it, so you see real prices before deciding.',
                  ),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: Space.xxxl),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text, required this.tone});

  final String text;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: Space.xs),
          Expanded(child: Text(text, style: context.text.bodyMedium)),
        ],
      ),
    );
  }
}
