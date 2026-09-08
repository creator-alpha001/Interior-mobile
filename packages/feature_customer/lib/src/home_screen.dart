/// The home screen.
///
/// Editorial, not a tile grid. MOBILE.md §6.1: *"Editorial hero in Newsreader;
/// do not turn it into a tile grid."* The four trades are the entry, and the
/// guarantee panel below them is the prototype's device filled with what is
/// actually true here rather than with escrow promises.
library;

import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domains = ref.watch(domainsProvider);
    final requirements = ref.watch(requirementsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(domainsProvider)
              ..invalidate(requirementsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            children: [
              const SizedBox(height: Space.xl),
              // The product's name. Not translated, in any locale.
              Text('Aangan', style: context.text.displayLarge),
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
                          : context.t('Quotes are ready for {n} of your jobs', {
                              'n': waiting.length,
                            }),
                      body: context.t(
                        'Compare them and choose a professional. Nothing '
                        'moves until you do.',
                      ),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
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
              AsyncView(
                value: domains,
                onRetry: () => ref.invalidate(domainsProvider),
                data: (list) => Column(
                  children: [
                    for (final domain in list.where((d) => d.isActive)) ...[
                      AanganCard(
                        onTap: onStart,
                        padding: const EdgeInsets.all(Space.cardPaddingWide),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Trade names come from the API. They are
                                  // data, not copy, and are translated there
                                  // or not at all.
                                  Text(
                                    domain.name,
                                    style: context.text.headlineSmall,
                                  ),
                                  const SizedBox(height: Space.xxs),
                                  Text(
                                    domain.tagline,
                                    style: context.text.bodyMedium?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Space.xs),
                    ],
                  ],
                ),
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
              AanganCard(
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
                          AanganMedia(src: banner.imageUrl, alt: banner.title),
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
                        child: AanganCard(
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
            // Sage: each of these is something a person at Aangan does.
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
