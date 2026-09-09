/// A professional's profile, and the gallery of everybody's work.
///
/// The web's `/professionals/[id]` and `/our-work`. `getProfessional` and
/// `listPortfolio` were both unreachable from the app, which meant the Explore
/// tab could list professionals and offer no way to look at one.
///
/// **Ratings are per trade, and the profile has to say which.** A professional
/// excellent at painting and average at carpentry is exactly that, and an
/// overall average printed under a trade heading is the wrong number under the
/// right label. `domainStats` carries the per-trade figures and this screen
/// leads with them.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

final professionalProvider = FutureProvider.family<ProfessionalProfile, String>(
  (ref, id) {
    return ref
        .watch(customerApiProvider)
        .public
        .getProfessional(id: id)
        .orThrow();
  },
);

final portfolioProvider = FutureProvider.family<List<PortfolioItem>, String?>((
  ref,
  domainSlug,
) {
  return ref
      .watch(customerApiProvider)
      .public
      .listPortfolio(domain: domainSlug, limit: 60)
      .orThrow();
});

class ProfessionalScreen extends ConsumerWidget {
  const ProfessionalScreen({super.key, required this.id, this.onRequest});

  final String id;

  /// Opens the requirement flow. The web's CTA is "Request this professional"
  /// and it is a *preference*, not a booking — ops try to honour it and the
  /// copy must not promise more than that.
  final void Function(ProfessionalProfile professional)? onRequest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final professional = ref.watch(professionalProvider(id));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: AsyncView(
          value: professional,
          onRetry: () => ref.invalidate(professionalProvider(id)),
          data: (profile) => _Profile(profile: profile, onRequest: onRequest),
        ),
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.profile, this.onRequest});

  final ProfessionalProfile profile;
  final void Function(ProfessionalProfile professional)? onRequest;

  @override
  Widget build(BuildContext context) {
    // Trades this professional is actually approved for, with their own
    // figures. Anything else is not something they can be asked to quote.
    final approved = profile.domainStats
        .where((d) => d.verificationStatus == DomainApprovalStatus.approved)
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
      children: [
        const SizedBox(height: Space.md),
        Row(
          children: [
            Expanded(
              child: Text(
                profile.companyName,
                style: context.text.displayLarge,
              ),
            ),
            if (profile.isVerified)
              // Sage: a person at InterioBee checked them.
              StatusPill(context.t('Verified'), tone: StatusTone.verified),
          ],
        ),
        const SizedBox(height: Space.xs),
        Text(
          context.t('{city} · {n} years', {
            'city': profile.city.name,
            'n': profile.experienceYears.round(),
          }),
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),

        if (profile.bio.isNotEmpty) ...[
          const SizedBox(height: Space.md),
          Text(profile.bio, style: context.text.bodyLarge),
        ],

        /// Per trade, and the point of the screen.
        ///
        /// A single average here would be the wrong number under the right
        /// label — and leads are ranked by the rating *in the trade being
        /// browsed*, so this is also what decides whether they ever appear.
        SectionHead(
          context.t('Rated by trade'),
          eyebrow: context.t('Not one average'),
        ),
        for (final stat in approved) _TradeRow(stat: stat, profile: profile),

        SectionHead(
          context.t('Where they work'),
          eyebrow: context.t('Service areas'),
        ),
        Wrap(
          spacing: Space.xxs,
          runSpacing: Space.xxs,
          children: [
            for (final city in profile.serviceCities)
              StatusPill(city.name, tone: StatusTone.neutral),
          ],
        ),

        if (profile.languages.isNotEmpty) ...[
          const SizedBox(height: Space.sm),
          Text(
            context.t('Speaks {languages}', {
              'languages': profile.languages.join(', '),
            }),
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],

        if (profile.portfolio.isNotEmpty) ...[
          SectionHead(
            context.t('Their work'),
            eyebrow: context.t('Approved for the public profile'),
          ),
          for (final item in profile.portfolio) _PortfolioCard(item: item),
        ],

        if (profile.reviews.isNotEmpty) ...[
          SectionHead(
            context.t('Reviews'),
            eyebrow: context.t('From completed jobs'),
          ),
          for (final review in profile.reviews.take(5))
            _ReviewCard(review: review),
        ],

        if (onRequest != null) ...[
          const SizedBox(height: Space.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => onRequest!(profile),
              child: Text(context.t('Request this professional')),
            ),
          ),
          const SizedBox(height: Space.xs),
          Text(
            /// The one sentence this screen cannot get wrong.
            ///
            /// Assignment is ops' decision. Naming somebody is a preference
            /// they try to honour, and a customer who reads it as a booking
            /// and then receives three other quotes has been misled by us.
            context.t(
              'We pass this on as a preference and try to honour it. You will '
              'still see quotes from others, so you can compare.',
            ),
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: Space.xxxl),
      ],
    );
  }
}

class _TradeRow extends StatelessWidget {
  const _TradeRow({required this.stat, required this.profile});

  final ProfessionalDomain stat;
  final ProfessionalProfile profile;

  @override
  Widget build(BuildContext context) {
    final domain = profile.domains
        .where((d) => d.id == stat.domainId)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xs),
      child: InterioBeeCard(
        padding: const EdgeInsets.all(Space.cardPaddingWide),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    domain?.name ?? context.t('This trade'),
                    style: context.text.headlineSmall,
                  ),
                ),
                Text(
                  stat.ratingCount == 0
                      ? context.t('Not yet rated')
                      : '${stat.avgRating.toStringAsFixed(1)} ★',
                  style: context.text.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: Space.xxs),
            Text(
              context.l10n.plural(
                stat.completedProjects,
                '{n} job completed',
                '{n} jobs completed',
              ),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({required this.item});

  final PortfolioItem item;

  @override
  Widget build(BuildContext context) {
    final media = [
      for (final asset in item.media)
        MediaItem(url: asset.url, caption: asset.caption ?? item.title),
    ];

    /// **The work first, full width.**
    ///
    /// This used to be a title, a description and a `MediaStrip` — 128×96
    /// thumbnails in a horizontal rail. That component is right where a
    /// photograph is *evidence* attached to something else: several proof
    /// shots inside a stage card. It is wrong here, where the photograph is
    /// the entire point, and it left every card a wide empty rectangle with
    /// one small tile marooned at the bottom left.
    ///
    /// The web's `/our-work` leads with the image at full width. So does this.
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: InterioBeeCard(
        padding: EdgeInsets.zero,
        onTap: media.isEmpty
            ? null
            : () => showMediaViewer(context, items: media),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (media.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Radii.panel),
                ),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: InterioBeeMedia(
                    src: media.first.url,
                    alt: media.first.caption,
                    rounded: false,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(Space.cardPaddingWide),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: context.text.titleLarge),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: Space.xxs),
                    Text(
                      item.description,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],

                  /// The rest of the set, when there is one.
                  ///
                  /// The strip earns its place here — these are secondary to
                  /// the photograph above, which is exactly what it is for.
                  if (media.length > 1) ...[
                    const SizedBox(height: Space.sm),
                    MediaStrip(items: media),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ReviewView review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xs),
      child: InterioBeeCard(
        padding: const EdgeInsets.all(Space.cardPaddingWide),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    // Reviews are per trade, like the ratings above them.
                    review.domain.name,
                    style: context.text.titleMedium,
                  ),
                ),
                Text(
                  '${review.review.rating} ★',
                  style: context.text.titleMedium,
                ),
              ],
            ),
            if (review.review.comment.isNotEmpty) ...[
              const SizedBox(height: Space.xxs),
              Text(review.review.comment, style: context.text.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

/// The web's `/our-work`: everybody's approved portfolio, in one place.
class OurWorkScreen extends ConsumerStatefulWidget {
  const OurWorkScreen({super.key, this.domainSlug});

  /// The trade to open on, when something routed here with one in mind.
  final String? domainSlug;

  @override
  ConsumerState<OurWorkScreen> createState() => _OurWorkScreenState();
}

class _OurWorkScreenState extends ConsumerState<OurWorkScreen> {
  late String? _domainSlug = widget.domainSlug;

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider(_domainSlug));

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Our work'))),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: Space.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              child: Text(
                context.t(
                  'Jobs already finished, photographed on site. Every one was '
                  'checked by our team before it appeared here.',
                ),
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: Space.sm),

            /// The web says why this filter is here, and it is worth repeating:
            /// a painter's work should not be judged against a fabricator's.
            FilterRow(
              label: context.t('Trade'),
              allLabel: context.t('All'),
              selected: _domainSlug,
              options: ref
                  .watch(domainsProvider)
                  .maybeWhen(
                    data: (list) => [for (final d in list) (d.slug, d.name)],
                    orElse: () => const <(String, String)>[],
                  ),
              onSelect: (slug) => setState(() => _domainSlug = slug),
            ),
            const SizedBox(height: Space.sm),

            AsyncView(
              value: portfolio,
              onRetry: () => ref.invalidate(portfolioProvider(_domainSlug)),
              data: (items) => items.isEmpty
                  ? EmptyState(
                      title: context.t('Nothing published yet'),
                      body: _domainSlug == null
                          ? context.t(
                              'Work appears here once our team has approved '
                              'it for a public profile.',
                            )
                          : context.t(
                              'No approved work in this trade yet. Try '
                              'another, or tell us what you need.',
                            ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.gutter,
                      ),
                      child: Column(
                        children: [
                          for (final item in items) _PortfolioCard(item: item),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }
}
