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
import 'filter_choices.dart';
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

/// Every professional, by id, to attribute and filter the gallery.
///
/// City and rating belong to the professional rather than to the piece of
/// work, so they are applied against this. Paged, as the web pages it: the
/// contract caps a page at 100, and the web's single over-large request once
/// turned the whole of `/our-work` into an error page.
final portfolioDirectoryProvider =
    FutureProvider<Map<String, ProfessionalSummary>>((ref) async {
      final api = ref.watch(customerApiProvider).public;
      final byId = <String, ProfessionalSummary>{};
      String? cursor;
      do {
        final page = await api
            .listProfessionals(cursor: cursor, limit: 100)
            .orThrow();
        for (final pro in page.items) {
          byId[pro.id] = pro;
        }
        // An empty page with a cursor would otherwise loop for ever.
        if (page.items.isEmpty) break;
        cursor = page.nextCursor;
      } while (cursor != null);
      return byId;
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
              // Sage: a person at Decora Shine checked them.
              StatusPill(context.t('Verified'), tone: StatusTone.verified),
          ],
        ),
        const SizedBox(height: Space.xs),
        Text(
          profile.city == null
              ? context.t('{n} years', {'n': profile.experienceYears.round()})
              : context.t('{city} · {n} years', {
                  'city': profile.city!.name,
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
          for (final item in profile.portfolio)
            _PortfolioCard(
              item: item,
              domainSlug:
                  profile.domains
                      .where((d) => d.id == item.domainId)
                      .firstOrNull
                      ?.slug ??
                  'default',
            ),
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
  const _PortfolioCard({
    required this.item,
    required this.domainSlug,
    this.professional,
  });

  final PortfolioItem item;

  /// The trade's slug, which picks the stock photograph for a piece of work
  /// that has none uploaded yet.
  final String domainSlug;

  /// Who did it, when the gallery knows. Null on their own profile, where it
  /// would only repeat the page's heading.
  final ProfessionalSummary? professional;

  @override
  Widget build(BuildContext context) {
    final media = [
      for (final asset in item.media)
        MediaItem(url: asset.url, caption: asset.caption ?? item.title),
    ];
    final pro = professional;

    /// **The work first, full width.**
    ///
    /// The web's `/our-work` leads with the image at full width, and so does
    /// this. A piece with no upload still gets a photograph from its trade's
    /// pool rather than a card with no picture — the client's rule is that
    /// nothing goes without one.
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(Radii.panel),
              ),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: InterioBeeMedia(
                  src: media.isEmpty
                      ? 'ph:$domainSlug:${item.id}'
                      : media.first.url,
                  alt: media.isEmpty ? item.title : media.first.caption,
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

                  /// The lines a customer skims, then the vendor's own
                  /// account of the job. Both are what they wrote on the web
                  /// or in the app, and the API has already reduced the HTML
                  /// to the tags this renders.
                  if (item.highlights.isNotEmpty) ...[
                    const SizedBox(height: Space.sm),
                    InterioBeeHighlights(item.highlights),
                  ],
                  if (item.details.isNotEmpty) ...[
                    const SizedBox(height: Space.xs),
                    InterioBeeHtml(item.details),
                  ],

                  /// The rest of the set, when there is one.
                  if (media.length > 1) ...[
                    const SizedBox(height: Space.sm),
                    MediaStrip(items: media),
                  ],

                  /// Each piece of work links back to the person who did it,
                  /// rather than floating free — as on the web.
                  if (pro != null) ...[
                    const SizedBox(height: Space.sm),
                    const InterioBeeDivider(inset: 0),
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfessionalScreen(id: pro.id),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: Space.sm),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: context.colors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: ExcludeSemantics(
                                child: Text(
                                  pro.name.trim().isEmpty
                                      ? ''
                                      : pro.name.trim()[0].toUpperCase(),
                                  style: context.text.labelMedium?.copyWith(
                                    color: context.colors.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: Space.xs),
                            Expanded(
                              child: Text(
                                pro.companyName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodyMedium,
                              ),
                            ),
                            if (pro.city != null)
                              Text(
                                pro.city!.name,
                                style: context.text.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
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

/// How the gallery is ordered. The web's three, in its order.
enum _WorkSort { recommended, rating, projects }

/// The web's `/our-work`: everybody's approved portfolio, in one place.
class OurWorkScreen extends ConsumerStatefulWidget {
  const OurWorkScreen({super.key, this.domainSlug});

  /// The trade to open on, when something routed here with one in mind.
  final String? domainSlug;

  @override
  ConsumerState<OurWorkScreen> createState() => _OurWorkScreenState();
}

class _OurWorkScreenState extends ConsumerState<OurWorkScreen> {
  static const _ratings = <double>[4.5, 4];

  late String? _domainSlug = widget.domainSlug;
  String? _cityId;
  double? _minRating;
  _WorkSort _sort = _WorkSort.recommended;

  /// What the Filter button counts: the sheet's contents, not trade or sort.
  int get _activeCount => [_cityId, _minRating].where((v) => v != null).length;

  static String _sortLabel(BuildContext context, _WorkSort sort) =>
      switch (sort) {
        _WorkSort.recommended => context.t('Recommended'),
        _WorkSort.rating => context.t('Top-rated professionals'),
        _WorkSort.projects => context.t('Most experienced teams'),
      };

  List<PortfolioItem> _apply(
    List<PortfolioItem> all,
    Map<String, ProfessionalSummary> directory,
  ) {
    final kept = [
      for (final item in all)
        if (_matches(directory[item.professionalId])) item,
    ];
    if (_sort == _WorkSort.recommended) return kept;

    num score(PortfolioItem item) {
      final pro = directory[item.professionalId];
      return _sort == _WorkSort.rating
          ? (pro?.avgRating ?? 0)
          : (pro?.completedProjects ?? 0);
    }

    // Stable, so pieces by equally ranked professionals keep the API's order.
    final ranked = kept.indexed.toList()
      ..sort((a, b) {
        final byScore = score(b.$2).compareTo(score(a.$2));
        return byScore != 0 ? byScore : a.$1.compareTo(b.$1);
      });
    return [for (final (_, item) in ranked) item];
  }

  bool _matches(ProfessionalSummary? pro) {
    if (_cityId != null && pro?.city?.id != _cityId) return false;
    final floor = _minRating;
    if (floor != null && (pro?.avgRating ?? 0) < floor) return false;
    return true;
  }

  Future<void> _openFilters() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      builder: (_) => StatefulBuilder(
        builder: (sheetContext, setSheet) {
          void change(VoidCallback update) {
            setState(update);
            setSheet(() {});
          }

          return SafeArea(
            child: Consumer(
              builder: (context, ref, _) {
                final cities = ref
                    .watch(citiesProvider)
                    .maybeWhen(data: (l) => l, orElse: () => const <City>[]);

                return ListView(
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
                        if (_activeCount > 0)
                          TextButton(
                            onPressed: () {
                              change(() {
                                _cityId = null;
                                _minRating = null;
                              });
                              Navigator.of(sheetContext).pop();
                            },
                            child: Text(context.t('Clear all')),
                          ),
                      ],
                    ),
                    SectionHead(context.t('City')),
                    FilterChoices<String>(
                      options: [
                        (null, context.t('All cities')),
                        for (final city in cities) (city.id, city.name),
                      ],
                      selected: _cityId,
                      onSelect: (id) => change(() => _cityId = id),
                    ),
                    SectionHead(context.t('Professional’s rating')),
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
                      selected: _minRating,
                      onSelect: (r) => change(() => _minRating = r),
                    ),
                    const SizedBox(height: Space.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(context.t('Show results')),
                      ),
                    ),
                    const SizedBox(height: Space.xxxl),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider(_domainSlug));
    final directory = ref
        .watch(portfolioDirectoryProvider)
        .maybeWhen(
          data: (byId) => byId,
          orElse: () => const <String, ProfessionalSummary>{},
        );
    final domains = ref
        .watch(domainsProvider)
        .maybeWhen(data: (list) => list, orElse: () => const <Domain>[]);
    final slugById = {for (final d in domains) d.id: d.slug};
    final filtered = _domainSlug != null || _activeCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('Our work')),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: _activeCount > 0,
              label: Text('$_activeCount'),
              child: const Icon(Icons.tune),
            ),
            tooltip: context.t('Filter'),
          ),
        ],
      ),
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
              options: [for (final d in domains) (d.slug, d.name)],
              onSelect: (slug) => setState(() => _domainSlug = slug),
            ),
            SizedBox(
              height: TapTarget.minimum,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
                children: [
                  for (final sort in _WorkSort.values) ...[
                    ChoiceChip(
                      label: Text(_sortLabel(context, sort)),
                      selected: _sort == sort,
                      onSelected: (_) => setState(() => _sort = sort),
                    ),
                    const SizedBox(width: Space.xs),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Space.xs),

            AsyncView(
              value: portfolio,
              onRetry: () => ref.invalidate(portfolioProvider(_domainSlug)),
              data: (all) {
                final items = _apply(all, directory);

                if (items.isEmpty) {
                  return EmptyState(
                    title: context.t('Nothing published yet'),
                    body: !filtered
                        ? context.t(
                            'Work appears here once our team has approved '
                            'it for a public profile.',
                          )
                        : _activeCount == 0
                        ? context.t(
                            'No approved work in this trade yet. Try '
                            'another, or tell us what you need.',
                          )
                        : context.t(
                            'Nothing matches these filters yet. Try clearing '
                            'one, or tell us what you need.',
                          ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.plural(
                          items.length,
                          '{n} project',
                          '{n} projects',
                        ),
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: Space.xs),
                      for (final item in items)
                        _PortfolioCard(
                          item: item,
                          domainSlug: slugById[item.domainId] ?? 'default',
                          professional: directory[item.professionalId],
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }
}
