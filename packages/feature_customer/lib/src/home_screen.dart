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
              const SizedBox(height: Space.xxxl),
            ],
          ),
        ),
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
