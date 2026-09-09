/// The home screen.
///
/// Editorial, not a tile grid. MOBILE.md §6.1: *"Editorial hero in Newsreader;
/// do not turn it into a tile grid."* The four trades are the entry, and the
/// guarantee panel below them is the prototype's device filled with what is
/// actually true here rather than with escrow promises.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agreements_screen.dart';
import 'async_view.dart';
import 'projects_screen.dart';
import 'providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onStart,
    required this.onOpenJobs,
    this.onSignIn,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(domainsProvider);
    final requirements = ref.watch(requirementsProvider);
    final agreements = ref.watch(agreementsProvider);
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(domainsProvider)
              ..invalidate(requirementsProvider)
              ..invalidate(agreementsProvider)
              ..invalidate(projectsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            children: [
              const SizedBox(height: Space.xl),
              // The product's name. Not translated, in any locale.
              Text('InterioBee', style: context.text.displayLarge),
              const SizedBox(height: Space.sm),
              Text(
                context.t(
                  'Interior design, furniture, fabrication and painting — with '
                  'one person who answers.',
                ),
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),

              /// Anything waiting on the customer comes before everything else.
              ///
              /// The peach panel means "you are the blocker" and nothing else,
              /// so it is only built when that is true.
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

                  return Padding(
                    padding: const EdgeInsets.only(top: Space.lg),
                    child: ActionRequired(
                      title: waiting.length == 1
                          ? context.t('Quotes are ready for your {trade}', {
                              'trade': waiting.first.domain.name.toLowerCase(),
                            })
                          /// **Trades, not jobs.**
                          ///
                          /// `waiting` counts services, and a job can carry
                          /// several — so one requirement with quotes on its
                          /// furniture and its painting made this say "2 of
                          /// your jobs" directly above a row saying "1 needs
                          /// you". Both numbers were right about their own
                          /// unit and the screen contradicted itself.
                          ///
                          /// A job is the requirement, which is what the Jobs
                          /// tab lists and numbers. A trade is a track inside
                          /// it, which is what gets quoted. This counts
                          /// trades and says trades.
                          : context.t(
                              'Quotes are ready on {n} of your trades',
                              {'n': waiting.length},
                            ),
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

              /// **The customer's own work, above everything we want to sell
              /// them.**
              ///
              /// §6.1 asks for an editorial home rather than a tile grid, and
              /// this keeps that — it is a short list of rows, not a grid of
              /// metrics. But a signed-in customer with a job under way did
              /// not come here to read the four trades again, and until now
              /// the only route to their own work was to know which tab it
              /// was under.
              if (onSignIn != null)
                Padding(
                  padding: const EdgeInsets.only(top: Space.lg),
                  child: InterioBeeCard(
                    padding: const EdgeInsets.all(Space.cardPaddingWide),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t('Already asked us for something?'),
                          style: context.text.headlineSmall,
                        ),
                        const SizedBox(height: Space.xxs),
                        Text(
                          context.t(
                            'Sign in with the number you gave us and your '
                            'jobs, quotes and messages come back.',
                          ),
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: Space.md),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: onSignIn,
                                child: Text(context.t('Sign in')),
                              ),
                            ),
                            const SizedBox(width: Space.xs),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onStart,
                                child: Text(context.t('Get quotes')),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else
                _YourWork(
                  requirements: requirements,
                  agreements: agreements,
                  projects: projects,
                  onOpenJobs: onOpenJobs,
                  onStart: onStart,
                ),

              /// The banner strip.
              ///
              /// Absent rather than empty when it fails or has nothing: a
              /// promotional carousel is the one thing on this screen nobody
              /// came for, and an error box where one would be is worse than
              /// the space it occupies.
              _Banners(),

              SectionHead(
                context.t('What do you need?'),
                eyebrow: context.t('Four trades'),
              ),

              /// **A grid of tiles, not four full-width rows.**
              ///
              /// Four rows of a name and a tagline ran most of a screen and
              /// read as a settings list. Two columns puts the whole choice in
              /// view at once, which is what a chooser should do.
              ///
              /// The web's equivalent block is deliberately imageless — its
              /// comment argues a trade is better identified by its name and a
              /// colour than by "a gradient pretending to be a room". This
              /// departs from that at the client's request: the tiles carry
              /// the same deterministic `ph:` art as the catalogue and the
              /// packages, so the four trades look like the rest of the app
              /// rather than like a list that lost its pictures.
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
                    // Tile plus two lines of name and one of meta. Tuned
                    // against the longest name the seed has, "Interior
                    // Design", which wraps at this width.
                    childAspectRatio: 0.86,
                    children: [
                      for (final domain in active)
                        _TradeTile(
                          domain: domain,
                          count: counts[domain.id],
                          onTap: onStart,
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: Space.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onStart,
                  child: Text(context.t('Tell us what you need')),
                ),
              ),

              /// The guarantee panel, filled with what is actually true.
              ///
              /// The prototype's version promised escrow. This one promises the
              /// four things the platform genuinely does, and nothing it does
              /// not — payments are off-platform, and saying otherwise here
              /// would be the most damaging sentence in the app.
              SectionHead(
                context.t('What you get'),
                eyebrow: context.t('Every job'),
              ),
              InterioBeeCard(
                padding: const EdgeInsets.all(Space.cardPaddingWide),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Promise(
                      title: context.t('Verified professionals'),
                      body: context.t(
                        'Every one is checked by us before they can quote, '
                        'and approved trade by trade.',
                      ),
                    ),
                    _Promise(
                      title: context.t('Ratings for the actual trade'),
                      body: context.t(
                        'A good carpenter is not automatically a good '
                        'painter, so they are rated separately.',
                      ),
                    ),
                    _Promise(
                      title: context.t('One person who answers'),
                      body: context.t(
                        'You talk to us, not to four tradespeople. We carry '
                        'messages both ways.',
                      ),
                    ),
                    _Promise(
                      title: context.t('Stages checked against photographs'),
                      body: context.t(
                        'Work counts as done when our team has seen '
                        'evidence of it — not when somebody says so.',
                      ),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              /// What other people got, and what the platform has done.
              ///
              /// Both are below the guarantee panel rather than above the
              /// trades: somebody who opened the app to get a wardrobe quoted
              /// should reach the four trades first, and social proof is what
              /// they read on the way back up if they hesitate.
              _Testimonials(),
              _Stats(),

              const SizedBox(height: Space.xxxl),
            ],
          ),
        ),
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
                          InterioBeeMedia(src: banner.imageUrl, alt: banner.title),
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
                  height: 170,
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
                          padding: const EdgeInsets.all(Space.cardPaddingWide),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                // Their words, their name, their city — all
                                // from the row, none of it composed here.
                                '${testimonial.clientName}, '
                                '${testimonial.cityName}',
                                style: context.text.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
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
class _YourWork extends StatelessWidget {
  const _YourWork({
    required this.requirements,
    required this.agreements,
    required this.projects,
    required this.onOpenJobs,
    required this.onStart,
  });

  final AsyncValue<List<LeadView>> requirements;
  final AsyncValue<List<AgreementView>> agreements;
  final AsyncValue<List<ProjectView>> projects;
  final VoidCallback onOpenJobs;
  final VoidCallback onStart;

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

    /// Nothing at all, and we know it — `data` came back empty rather than
    /// failing. That distinction matters: telling somebody they have no jobs
    /// because the request 500'd would be a lie with a button on it.
    /// How many of those are held up by the reader rather than by us.
    final needsYou = live.where(_waitingOnCustomer).length;

    final knownEmpty =
        requirements.hasValue && live.isEmpty && toSign == 0 && running == 0;

    if (knownEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: Space.lg),
        child: InterioBeeCard(
          padding: const EdgeInsets.all(Space.cardPaddingWide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t('Nothing under way yet'),
                style: context.text.headlineSmall,
              ),
              const SizedBox(height: Space.xxs),
              Text(
                context.t(
                  'Tell us what you need and we will bring you three written '
                  'quotes for each trade. Free, and you are not committed to '
                  'any of them.',
                ),
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onStart,
                  child: Text(context.t('Get quotes')),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (live.isEmpty && toSign == 0 && running == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(context.t('Your work'), eyebrow: context.t('Still moving')),

        /// **One row for the jobs, not one row per job.**
        ///
        /// This listed every live requirement with its trades, its reference
        /// and its state — which is the Jobs tab, in a smaller font. Two
        /// screens showing the same list is not a dashboard; it is the same
        /// screen twice, and the second one is always the one that goes stale.
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

/// One trade, as a tile.
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
    return InterioBeeCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// The tile art.
          ///
          /// `bannerUrl` when the trade has one and a `ph:` token keyed to the
          /// slug otherwise, so the colour is stable for a given trade and
          /// matches the same trade's products in the catalogue.
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Radii.panel),
            ),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: InterioBeeMedia(
                src: (domain.bannerUrl?.isNotEmpty ?? false)
                    ? domain.bannerUrl!
                    : 'ph:${domain.slug}:${domain.slug}',
                alt: domain.name,
                rounded: false,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Space.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trade names come from the API. They are data, not copy,
                  // and are translated there or not at all.
                  Text(
                    domain.name,
                    style: context.text.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  /// What is actually behind the tile, as the web shows it.
                  /// A trade with a number beside it reads as something with
                  /// depth rather than as a category heading.
                  if (count != null)
                    Text(
                      context.t('{items} items · {packages} packages', {
                        'items': count!.products,
                        'packages': count!.packages,
                      }),
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
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
            // Sage: each of these is something a person at InterioBee does.
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
