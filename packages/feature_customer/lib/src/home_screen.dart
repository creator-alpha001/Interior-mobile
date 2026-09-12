/// The home screen.
///
/// Built around the website's promise, *Homes that feel like you*. A photograph
/// of a finished room carries the line and the two ways forward; the trades
/// follow as pictures rather than labels, and every section below has an image
/// — the client's rule is that nothing on the platform goes without one.
///
/// A customer's own work still comes before anything we want to sell them,
/// directly under the hero.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agreements_screen.dart';
import 'async_view.dart';
import 'about_screens.dart';
import 'blog_screen.dart';
import 'catalogue.dart';
import 'customer_shell.dart';
import 'packages_screen.dart';
import 'professional_screen.dart';
import 'projects_screen.dart';
import 'providers.dart';

/// What signup let this customer skip, and what to call them.
///
/// A value rather than the session, so this package still knows nothing of
/// the auth controller. The app builds it from `GET /me`.
@immutable
class SetupNeeds {
  const SetupNeeds({required this.city, required this.number, this.firstName});

  final bool city;

  /// No number on the account, or one that was never confirmed.
  final bool number;

  final String? firstName;

  bool get any => city || number;
}

/// "Not now", for as long as the app stays open.
///
/// Not persisted, as the web keeps it in `sessionStorage`: both questions are
/// still genuinely open, so a later launch may ask again.
final _setupDismissedProvider = StateProvider<bool>((ref) => false);

/// The home screen's own reads.
///
/// Deliberately not the catalogue's and the directory's providers: those carry
/// the filters somebody set on those screens, so home would quietly show
/// "4.5 stars and above in Lucknow" after a visit to Explore.
final _featuredProductsProvider = FutureProvider<List<ProductView>>((
  ref,
) async {
  final page = await ref
      .watch(customerApiProvider)
      .public
      .listProducts(limit: 8)
      .orThrow();
  return page.items;
});

final _homeProfessionalsProvider = FutureProvider<List<ProfessionalSummary>>((
  ref,
) async {
  final page = await ref
      .watch(customerApiProvider)
      .public
      .listProfessionals(limit: 3)
      .orThrow();
  return page.items;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onStart,
    required this.onOpenJobs,
    this.onSignIn,
    this.setup,
    this.onFinishSetup,
  });

  /// Non-null exactly when nobody is signed in.
  ///
  /// The home screen is public — every read above the dashboard is an
  /// anonymous one — so this is an offer rather than a gate. It sits where the
  /// dashboard would be, because that is the space a returning customer's own
  /// work occupies and the point is that they can get it back.
  final Future<bool> Function()? onSignIn;

  final VoidCallback onStart;

  /// Switches to the Jobs tab.
  ///
  /// Owned by the shell, because the tab index is. Without it the panel that
  /// says "quotes are ready" was a statement with nowhere to go — the reader
  /// had to be told, then find the tab themselves.
  final VoidCallback onOpenJobs;

  /// Null when signed out. Drives the greeting and the setup strip.
  final SetupNeeds? setup;

  /// Opens the screen that asks for a city and a number.
  final VoidCallback? onFinishSetup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(domainsProvider);
    final requirements = ref.watch(requirementsProvider);
    final agreements = ref.watch(agreementsProvider);
    final projects = ref.watch(projectsProvider);
    final dismissed = ref.watch(_setupDismissedProvider);
    final needs = setup;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(domainsProvider)
              ..invalidate(requirementsProvider)
              ..invalidate(agreementsProvider)
              ..invalidate(projectsProvider);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              /// The header: the mark, and the way in when nobody is signed in.
              ///
              /// Sign-in used to be a card below the hero, which put it a full
              /// screen down on a phone. The hero already carries "Get free
              /// design quotes", so the header carries the other action.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.gutter,
                  Space.xs,
                  Space.sm,
                  Space.xs,
                ),
                child: Row(
                  children: [
                    const DecoraShineLogo(height: 32),
                    const Spacer(),
                    if (onSignIn != null)
                      FilledButton(
                        onPressed: onSignIn,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.md,
                          ),
                        ),
                        child: Text(context.t('Sign in')),
                      ),
                  ],
                ),
              ),

              /// Above the hero, as the web puts its strip above the page.
              if (needs != null &&
                  needs.any &&
                  !dismissed &&
                  onFinishSetup != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.gutter,
                    0,
                    Space.gutter,
                    Space.sm,
                  ),
                  child: _SetupStrip(
                    needs: needs,
                    onFinish: onFinishSetup!,
                    onDismiss: () =>
                        ref.read(_setupDismissedProvider.notifier).state = true,
                  ),
                ),

              _Hero(
                firstName: needs?.firstName,
                onStart: onStart,
                onExplore: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OurWorkScreen()),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Anything waiting on the customer comes before
                    /// everything else below the hero.
                    ///
                    /// The peach panel means "you are the blocker" and nothing
                    /// else, so it is only built when that is true.
                    requirements.maybeWhen(
                      data: (list) {
                        final waiting = [
                          for (final lead in list)
                            for (final service in lead.domains)
                              if (service.quotes.isNotEmpty &&
                                  service.leadDomain.selectedQuoteId == null)
                                service,
                        ];
                        if (waiting.isEmpty) return const SizedBox.shrink();

                        /// **Trades, not jobs.**
                        ///
                        /// `waiting` counts services, and a job can carry
                        /// several. A job is the requirement, which is what
                        /// the Jobs tab lists; a trade is a track inside it,
                        /// which is what gets quoted. This counts trades and
                        /// says trades.
                        ///
                        /// Built here rather than inline: nested any deeper,
                        /// the formatter splits `context.t(` across two lines
                        /// and `l10n_test.dart` stops seeing the string.
                        final trade = waiting.first.domain.name.toLowerCase();
                        final title = waiting.length == 1
                            ? context.t('Quotes are ready for your {trade}', {
                                'trade': trade,
                              })
                            : context.t(
                                'Quotes are ready on {n} of your trades',
                                {'n': waiting.length},
                              );

                        return Padding(
                          padding: const EdgeInsets.only(top: Space.lg),
                          child: ActionRequired(
                            title: title,
                            body: context.t(
                              'Compare them and choose a professional. Nothing '
                              'moves until you do.',
                            ),
                            action: FilledButton(
                              onPressed: onOpenJobs,
                              child: Text(context.t('Compare quotes')),
                            ),
                          ),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),

                    // Signed out there is no work of theirs to show, and the
                    // way in is in the header.
                    if (onSignIn == null)
                      _YourWork(
                        requirements: requirements,
                        agreements: agreements,
                        projects: projects,
                        onOpenJobs: onOpenJobs,
                      ),

                    /// The banner strip. Absent rather than empty when it fails
                    /// or has nothing: it is the one thing here nobody came for.
                    _Banners(),

                    SectionHead(
                      context.t('A room, a piece or a wall'),
                      eyebrow: context.t('Start with what you need'),
                    ),

                    /// The trades as photographs, as the web draws them.
                    ///
                    /// Each opens its own catalogue rather than the requirement
                    /// form: somebody who taps "Painting" wants to see painting.
                    /// The hero's button is the way straight to quotes.
                    AsyncView(
                      value: domains,
                      onRetry: () => ref.invalidate(domainsProvider),
                      data: (list) {
                        final active = list.where((d) => d.isActive).toList();
                        final counts = ref
                            .watch(catalogueCountsProvider)
                            .maybeWhen(
                              data: (rows) => {
                                for (final row in rows) row.domainId: row,
                              },
                              orElse: () => const <String, CatalogueCount>{},
                            );

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: Space.xs,
                          crossAxisSpacing: Space.xs,
                          childAspectRatio: 0.78,
                          children: [
                            for (final domain in active)
                              _TradeTile(
                                domain: domain,
                                count: counts[domain.id],
                                onTap: () =>
                                    openCatalogue(context, ref, domain: domain),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: Space.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => openCatalogue(context, ref),
                        child: Text(context.t('Full catalogue')),
                      ),
                    ),

                    /// Everything the web's home carries below the trades.
                    /// Rows of real records rather than links: a phone screen
                    /// is read by scrolling, and a list of section names is
                    /// not a home page.
                    _ProductsRow(),
                    _PackagesRow(onStart: onStart),
                    const _HowItWorks(),
                    _ProfessionalsRow(),

                    _Stats(),

                    /// The guarantee panel, filled with what is actually true.
                    ///
                    /// The prototype's version promised escrow. This one
                    /// promises the four things the platform genuinely does,
                    /// and nothing it does not — payments are off-platform, and
                    /// saying otherwise here would be the most damaging
                    /// sentence in the app.
                    SectionHead(
                      context.t('What you get'),
                      eyebrow: context.t('Every job'),
                    ),
                    InterioBeeCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(Radii.panel),
                            ),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: ExcludeSemantics(
                                child: InterioBeeMedia(
                                  src: 'ph:interior:what-you-get',
                                  alt: '',
                                  rounded: false,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(
                              Space.cardPaddingWide,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Promise(
                                  title: context.t('Verified professionals'),
                                  body: context.t(
                                    'Every one is checked by us before they can '
                                    'quote, and approved trade by trade.',
                                  ),
                                ),
                                _Promise(
                                  title: context.t(
                                    'Ratings for the actual trade',
                                  ),
                                  body: context.t(
                                    'A good carpenter is not automatically a '
                                    'good painter, so they are rated '
                                    'separately.',
                                  ),
                                ),
                                _Promise(
                                  title: context.t('One person who answers'),
                                  body: context.t(
                                    'You talk to us, not to four tradespeople. '
                                    'We carry messages both ways.',
                                  ),
                                ),
                                _Promise(
                                  title: context.t(
                                    'Stages checked against photographs',
                                  ),
                                  body: context.t(
                                    'Work counts as done when our team has seen '
                                    'evidence of it — not when somebody says '
                                    'so.',
                                  ),
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// What other people got. Below the guarantee panel rather
                    /// than above the trades: somebody who opened the app to
                    /// get a wardrobe quoted should reach the trades first.
                    _Testimonials(),
                    _GuidesRow(),
                    _ClosingCta(onStart: onStart),

                    const SizedBox(height: Space.xxxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The promise, over a photograph of a finished room.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.firstName,
    required this.onStart,
    required this.onExplore,
  });

  final String? firstName;
  final VoidCallback onStart;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final soft = Colors.white.withValues(alpha: 0.85);

    return Stack(
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: InterioBeeMedia(
              src: StockPhotos.hero(1) ?? 'ph:interior:hero-1',
              alt: '',
              rounded: false,
            ),
          ),
        ),

        /// Darkest behind the words, clear over the room.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.82),
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.08),
                ],
              ),
            ),
          ),
        ),
        Padding(
          // Sized for a handset, not a laptop: the first version borrowed the
          // web's proportions and took most of a six-inch screen before
          // anything else appeared.
          padding: const EdgeInsets.fromLTRB(
            Space.gutter,
            Space.xxl,
            Space.gutter,
            Space.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firstName == null
                    ? context.t(
                        'Interiors · Furniture · Fabrication · Painting',
                      )
                    : context.t('Welcome back, {name}', {'name': firstName}),
                style: context.text.labelMedium?.copyWith(color: soft),
              ),
              const SizedBox(height: Space.xs),
              Text(
                context.t('Homes that feel like you'),
                style: context.text.displayLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                  height: 35 / 30,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: Space.sm),
              Text(
                context.t(
                  'Design, furniture and finishes shaped around how you live '
                  '— by verified local professionals.',
                ),
                style: context.text.bodyMedium?.copyWith(color: soft),
              ),
              const SizedBox(height: Space.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: InterioBeeColors.chalk,
                    foregroundColor: InterioBeeColors.ink,
                  ),
                  onPressed: onStart,
                  child: Text(context.t('Get free design quotes')),
                ),
              ),
              const SizedBox(height: Space.xs),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  onPressed: onExplore,
                  child: Text(context.t('Explore designs')),
                ),
              ),
              const SizedBox(height: Space.md),
              for (final line in [
                context.t('Verified professionals, per trade'),
                context.t('Your number is never shared'),
                context.t('One written agreement to handover'),
              ])
                Padding(
                  padding: const EdgeInsets.only(top: Space.xxs),
                  child: Row(
                    children: [
                      Icon(Icons.check, size: 16, color: soft),
                      const SizedBox(width: Space.xs),
                      Expanded(
                        child: Text(
                          line,
                          style: context.text.bodySmall?.copyWith(color: soft),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The two questions signup let a customer skip, as one highlighted strip.
///
/// The web's `SetupNudge`, word for word. In the accent colour with an icon
/// and a filled button, because a number the team can ring about quotes is
/// worth being noticed — but one strip, dismissible, and never a card that
/// takes the first screen.
class _SetupStrip extends StatelessWidget {
  const _SetupStrip({
    required this.needs,
    required this.onFinish,
    required this.onDismiss,
  });

  final SetupNeeds needs;
  final VoidCallback onFinish;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final headline = needs.number && needs.city
        ? context.t('Add your mobile number and city')
        : needs.number
        ? context.t('Add your mobile number')
        : context.t('Choose your city');
    final reason = needs.number
        ? context.t(
            'So our team can call you about your quotes. It is never shared '
            'with professionals.',
          )
        : context.t('So prices and professionals match where you live.');

    return Container(
      padding: const EdgeInsets.all(Space.cardPadding),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: Radii.panelRadius,
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  needs.number ? Icons.phone_outlined : Icons.place_outlined,
                  size: 18,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: context.text.titleMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: Space.xxs),
                    Text(
                      reason,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(
                onPressed: onFinish,
                child: Text(
                  needs.number
                      ? context.t('Add mobile number')
                      : context.t('Choose your city'),
                ),
              ),
              TextButton(
                onPressed: onDismiss,
                style: TextButton.styleFrom(
                  foregroundColor: colors.onPrimaryContainer,
                ),
                child: Text(context.t('Not now')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The promotional strip. Silent when there is nothing to show.
class _Banners extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(bannersProvider)
        .maybeWhen(
          data: (banners) {
            final live = banners.where((b) => b.isActive).toList();
            if (live.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: Space.lg),
              child: SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: live.length,
                  separatorBuilder: (context, i) =>
                      const SizedBox(width: Space.sm),
                  itemBuilder: (context, i) {
                    final banner = live[i];
                    return SizedBox(
                      width: 280,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          InterioBeeMedia(
                            src: banner.imageUrl,
                            alt: banner.title,
                          ),
                          // A scrim, so the title stays legible over whatever
                          // photograph or generated tile sits behind it.
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: Radii.panelRadius,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.55),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(Space.cardPadding),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  banner.title,
                                  style: context.text.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  banner.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.bodySmall?.copyWith(
                                    color: Colors.white70,
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
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
  }
}

/// Customers' words, each over a photograph as the web shows them.
class _Testimonials extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(testimonialsProvider)
        .maybeWhen(
          data: (list) {
            if (list.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHead(
                  context.t('What people say'),
                  eyebrow: context.t('Finished jobs'),
                ),
                SizedBox(
                  height: 330,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length,
                    separatorBuilder: (context, i) =>
                        const SizedBox(width: Space.sm),
                    itemBuilder: (context, i) {
                      final testimonial = list[i];
                      return SizedBox(
                        width: 260,
                        child: InterioBeeCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(Radii.panel),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 16 / 10,
                                  child: ExcludeSemantics(
                                    child: InterioBeeMedia(
                                      src: 'ph:default:${testimonial.id}',
                                      alt: '',
                                      rounded: false,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    Space.cardPadding,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${testimonial.rating.toStringAsFixed(1)} ★',
                                        style: context.text.titleMedium,
                                      ),
                                      const SizedBox(height: Space.xxs),
                                      Expanded(
                                        child: Text(
                                          testimonial.quote,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.text.bodyMedium,
                                        ),
                                      ),
                                      const SizedBox(height: Space.xxs),
                                      Text(
                                        // Their words, their name, their city —
                                        // all from the row, none composed here.
                                        '${testimonial.clientName}, '
                                        '${testimonial.cityName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.text.bodySmall?.copyWith(
                                          color:
                                              context.colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
  }
}

class _Stats extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(platformStatsProvider)
        .maybeWhen(
          data: (stats) => Padding(
            padding: const EdgeInsets.only(top: Space.lg),
            child: Row(
              children: [
                _Stat(
                  value: '${stats.professionals}',
                  label: context.t('Professionals'),
                ),
                _Stat(
                  value: '${stats.projects}',
                  label: context.t('Jobs done'),
                ),
                _Stat(value: '${stats.cities}', label: context.t('Cities')),
                _Stat(
                  value: stats.avgRating.toStringAsFixed(1),
                  label: context.t('Average'),
                ),
              ],
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: context.text.headlineSmall),
          Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Everything of the customer's that is still moving, and a way into each.
///
/// Three sources, because the platform splits the journey across three: a
/// requirement while it is being quoted, an agreement at the moment it is
/// signed, and a project once work starts. A customer does not think of those
/// as three things, so they are listed together.
///
/// Nothing at all renders when nothing is moving. There used to be a "nothing
/// under way yet" card with its own button here; the hero above now carries
/// that invitation, and saying it twice on one screen was noise.
class _YourWork extends StatelessWidget {
  const _YourWork({
    required this.requirements,
    required this.agreements,
    required this.projects,
    required this.onOpenJobs,
  });

  final AsyncValue<List<LeadView>> requirements;
  final AsyncValue<List<AgreementView>> agreements;
  final AsyncValue<List<ProjectView>> projects;
  final VoidCallback onOpenJobs;

  @override
  Widget build(BuildContext context) {
    /// Only what has actually loaded. A failed read shows nothing rather than
    /// an error box — the rest of this screen is still worth reading, and the
    /// Jobs tab reports the failure properly when somebody goes looking.
    final live = requirements.maybeWhen(
      data: (list) => [
        for (final lead in list)
          if (lead.domains.any(_isLive)) lead,
      ],
      orElse: () => const <LeadView>[],
    );
    final toSign = agreements.maybeWhen(
      data: (list) =>
          list.where((a) => a.agreement.status == AgreementStatus.sent).length,
      orElse: () => 0,
    );
    final running = projects.maybeWhen(
      data: (list) =>
          list.where((p) => p.project.status == ProjectStatus.ongoing).length,
      orElse: () => 0,
    );

    /// How many of those are held up by the reader rather than by us.
    final needsYou = live.where(_waitingOnCustomer).length;

    if (live.isEmpty && toSign == 0 && running == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(context.t('Your work'), eyebrow: context.t('Still moving')),

        /// **One row for the jobs, not one row per job.**
        ///
        /// Home's question is "is anything waiting on me, and where do I go".
        /// The Jobs tab's is "what exactly is happening on each of them". So
        /// this counts, says whether any of it needs the reader, and hands
        /// over. The three rows below it lead to three *different* screens,
        /// which is the whole reason they are worth a row at all.
        if (live.isNotEmpty) ...[
          _WorkRow(
            title: context.l10n.plural(live.length, '{n} job', '{n} jobs'),
            subtitle: context.t('Quotes, visits and messages'),
            status: needsYou > 0
                ? context.l10n.plural(needsYou, '{n} needs you', '{n} need you')
                : context.t('All with us'),
            tone: needsYou > 0 ? StatusTone.yours : StatusTone.waiting,
            onTap: onOpenJobs,
          ),
          const SizedBox(height: Space.xs),
        ],
        if (toSign > 0) ...[
          _WorkRow(
            title: context.l10n.plural(
              toSign,
              '{n} agreement ready to sign',
              '{n} agreements ready to sign',
            ),
            subtitle: context.t('One per professional, not per job'),
            status: context.t('Your turn'),
            tone: StatusTone.yours,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AgreementsScreen())),
          ),
          const SizedBox(height: Space.xs),
        ],
        if (running > 0) ...[
          _WorkRow(
            title: context.l10n.plural(
              running,
              '{n} job under way',
              '{n} jobs under way',
            ),
            subtitle: context.t('Stage by stage, with photographs'),
            status: context.t('In progress'),
            tone: StatusTone.waiting,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProjectsScreen())),
          ),
          const SizedBox(height: Space.xs),
        ],
      ],
    );
  }

  /// A service still going somewhere. Completed and cancelled are neither.
  static bool _isLive(LeadDomainView service) =>
      service.leadDomain.status != LeadDomainStatus.completed &&
      service.leadDomain.status != LeadDomainStatus.cancelled;

  /// Quotes to choose outrank everything else, because they are the only
  /// state where the customer is the one holding the job up.
  static bool _waitingOnCustomer(LeadView lead) => lead.domains.any(
    (s) => s.quotes.isNotEmpty && s.leadDomain.selectedQuoteId == null,
  );
}

/// One line of the dashboard: what it is, where it stands, and a way in.
class _WorkRow extends StatelessWidget {
  const _WorkRow({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.tone,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String status;
  final StatusTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InterioBeeCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.headlineSmall),
                const SizedBox(height: Space.xxs),
                Text(
                  subtitle,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Space.xs),
                StatusPill(status, tone: tone),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
        ],
      ),
    );
  }
}

/// One trade, as a photograph with its name over it.
class _TradeTile extends StatelessWidget {
  const _TradeTile({
    required this.domain,
    required this.count,
    required this.onTap,
  });

  final Domain domain;
  final CatalogueCount? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final soft = Colors.white.withValues(alpha: 0.8);

    return ClipRRect(
      borderRadius: Radii.panelRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// `bannerUrl` when the trade has one, and otherwise the same seed
          /// the web uses, so a trade shows the same photograph on both.
          InterioBeeMedia(
            src: (domain.bannerUrl?.isNotEmpty ?? false)
                ? domain.bannerUrl!
                : 'ph:${domain.slug}:home-${domain.id}',
            alt: domain.name,
            rounded: false,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Space.cardPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trade names come from the API. They are data, not copy,
                // and are translated there or not at all.
                Text(
                  domain.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleLarge?.copyWith(color: Colors.white),
                ),
                if (domain.tagline.isNotEmpty) ...[
                  const SizedBox(height: Space.xxs),
                  Text(
                    domain.tagline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(color: soft),
                  ),
                ],

                /// What is behind the tile, as the web shows it.
                if (count != null) ...[
                  const SizedBox(height: Space.xs),
                  Text(
                    context.t('{items} designs · {packages} packages', {
                      'items': count!.products,
                      'packages': count!.packages,
                    }),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelMedium?.copyWith(color: soft),
                  ),
                ],
              ],
            ),
          ),

          /// On top, so the ripple shows over the photograph.
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}

class _Promise extends StatelessWidget {
  const _Promise({
    required this.title,
    required this.body,
    this.isLast = false,
  });

  final String title;
  final String body;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : Space.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: TapTarget.glyph,
            // Sage: each of these is something a person at Decora Shine does.
            color: context.palette.verified,
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleLarge),
                const SizedBox(height: Space.xxs),
                Text(
                  body,
                  style: context.text.bodyMedium?.copyWith(
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

/// A horizontal row of cards under a heading, with a way to the whole list.
///
/// Everything below the trades has this shape, so the spacing and the "see
/// all" are written once rather than five times.
class _Row extends StatelessWidget {
  const _Row({
    required this.eyebrow,
    required this.title,
    required this.height,
    required this.width,
    required this.count,
    required this.item,
    required this.onSeeAll,
  });

  final String eyebrow;
  final String title;
  final double height;
  final double width;
  final int count;
  final Widget Function(BuildContext context, int index) item;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          title,
          eyebrow: eyebrow,
          trailing: TextButton(
            onPressed: onSeeAll,
            child: Text(context.t('See all')),
          ),
        ),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: count,
            separatorBuilder: (context, i) => const SizedBox(width: Space.sm),
            itemBuilder: (context, i) =>
                SizedBox(width: width, child: item(context, i)),
          ),
        ),
      ],
    );
  }
}

/// Designs to start from. Silent until they arrive.
class _ProductsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(_featuredProductsProvider)
        .maybeWhen(
          data: (products) {
            if (products.isEmpty) return const SizedBox.shrink();
            return _Row(
              eyebrow: context.t('Designs to start from'),
              title: context.t('Pick a look. We make it to your size.'),
              height: 330,
              width: 186,
              count: products.length,
              item: (context, i) => ProductCard(view: products[i]),
              onSeeAll: () => openCatalogue(context, ref),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
  }
}

/// Fixed scopes at fixed prices, and what each one leaves out.
class _PackagesRow extends ConsumerWidget {
  const _PackagesRow({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(packagesProvider(null))
        .maybeWhen(
          data: (packages) {
            if (packages.isEmpty) return const SizedBox.shrink();
            return _Row(
              eyebrow: context.t('Ready-made packages'),
              title: context.t('Priced scopes, nothing hidden'),
              height: 350,
              width: 270,
              count: packages.length,
              item: (context, i) =>
                  PackageCard(view: packages[i], onStart: onStart),
              onSeeAll: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PackagesScreen(onStart: onStart),
                ),
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
  }
}

/// Three professionals, rated in the trade they were approved for.
class _ProfessionalsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(_homeProfessionalsProvider)
        .maybeWhen(
          data: (professionals) {
            if (professionals.isEmpty) return const SizedBox.shrink();
            return _Row(
              eyebrow: context.t('The people who do the work'),
              title: context.t('Verified, and rated per trade'),
              height: 340,
              width: 290,
              count: professionals.length,
              item: (context, i) =>
                  ProfessionalCard(professional: professionals[i]),
              onSeeAll: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const OurWorkScreen())),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
  }
}

/// What things cost, written by the people who do the work.
class _GuidesRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(blogPostsProvider)
        .maybeWhen(
          data: (page) {
            final posts = page.items.take(5).toList();
            if (posts.isEmpty) return const SizedBox.shrink();
            return _Row(
              eyebrow: context.t('Guides'),
              title: context.t('Know what you are buying'),
              height: 300,
              width: 260,
              count: posts.length,
              item: (context, i) => PostCard(view: posts[i]),
              onSeeAll: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const BlogScreen())),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
  }
}

/// The five steps, as pictures with their names.
///
/// Titles only, with the full explanation one tap away in "How it works": the
/// web can afford a paragraph under each, a phone row cannot, and the screen
/// that carries them properly already exists.
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  /// One seed per step, written out rather than built from the index: an
  /// interpolated token reads as copy to `l10n_test.dart`'s scan.
  static const _photos = <String>[
    'ph:default:step-1',
    'ph:default:step-2',
    'ph:default:step-3',
    'ph:interior:step-4',
    'ph:default:step-5',
  ];

  /// Written as literals at the call site, because `l10n_test.dart` reads the
  /// source for `context.t('...')` and cannot see a string passed as a value.
  static List<String> _titles(BuildContext context) => [
    context.t('Tell us how you live'),
    context.t('Meet three professionals'),
    context.t('They visit and quote'),
    context.t('Compare side by side'),
    context.t('Sign and move in'),
  ];

  @override
  Widget build(BuildContext context) {
    final titles = _titles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          context.t('From first idea to moving in'),
          eyebrow: context.t('How it works'),
        ),
        SizedBox(
          height: 186,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: titles.length,
            separatorBuilder: (context, i) => const SizedBox(width: Space.sm),
            itemBuilder: (context, i) => SizedBox(
              width: 150,
              child: InterioBeeCard(
                padding: EdgeInsets.zero,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HowItWorksScreen(onStart: null),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(Radii.panel),
                      ),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: ExcludeSemantics(
                          child: InterioBeeMedia(
                            src: _photos[i],
                            alt: '',
                            rounded: false,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(Space.cardPadding),
                        child: Text(
                          titles[i],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyMedium,
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
    );
  }
}

/// The last word, over a photograph, as the web closes its home page.
class _ClosingCta extends StatelessWidget {
  const _ClosingCta({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.xl),
      child: ClipRRect(
        borderRadius: Radii.panelRadius,
        child: Stack(
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: InterioBeeMedia(
                  src: StockPhotos.hero(2) ?? 'ph:interior:hero-2',
                  alt: '',
                  rounded: false,
                ),
              ),
            ),
            Positioned.fill(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.cardPaddingWide),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('Free, and nothing owed'),
                    style: context.text.labelMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    context.t('Start with a conversation about your home'),
                    style: context.text.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: Space.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: InterioBeeColors.chalk,
                        foregroundColor: InterioBeeColors.ink,
                      ),
                      onPressed: onStart,
                      child: Text(context.t('Get free design quotes')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
