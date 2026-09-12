/// Commission, performance and portfolio.
///
/// The three screens a vendor visits weekly rather than hourly, behind one tab.
///
/// Commission is here and appears nowhere on a customer surface — not because
/// a screen hides it, but because no customer-facing response carries the
/// figure. Per-trade performance is the point of the performance screen:
/// excellent at painting and average at carpentry is shown as exactly that,
/// because that is how leads are ranked and how they reach this vendor.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_core_upload/interiobee_core_upload.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agreements_screen.dart';
import 'async_view.dart';
import 'post_work_screen.dart';
import 'providers.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.queue, this.onSignOut});

  /// The upload queue, for posting work from the portfolio screen.
  final UploadQueue queue;

  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            const SizedBox(height: Space.md),
            Text(context.t('More'), style: context.text.headlineLarge),
            const SizedBox(height: Space.md),
            _Link(
              title: context.t('Commission'),
              subtitle: context.t('What you owe the platform'),
              onTap: () => _push(context, const InvoicesScreen()),
            ),
            const SizedBox(height: Space.xs),
            _Link(
              title: context.t('Performance'),
              subtitle: context.t('Your rating in each trade'),
              onTap: () => _push(context, const PerformanceScreen()),
            ),
            const SizedBox(height: Space.xs),
            _Link(
              title: context.t('Agreements'),
              subtitle: context.t('Contracts you have won'),
              onTap: () => _push(context, const VendorAgreementsScreen()),
            ),
            const SizedBox(height: Space.xs),
            _Link(
              title: context.t('Your profile'),
              subtitle: context.t('What customers see'),
              onTap: () => _push(context, const VendorProfileScreen()),
            ),
            const SizedBox(height: Space.xs),
            _Link(
              title: context.t('Portfolio'),
              subtitle: context.t('The work on your public profile'),
              onTap: () => _push(context, PortfolioScreen(queue: queue)),
            ),
            if (onSignOut != null) ...[
              const SizedBox(height: Space.xl),
              OutlinedButton(
                onPressed: onSignOut,
                child: Text(context.t('Sign out')),
              ),
            ],
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

class _Link extends StatelessWidget {
  const _Link({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InterioBeeCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleLarge),
                Text(
                  subtitle,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Commission'))),
      body: SafeArea(
        child: AsyncView(
          value: invoices,
          onRetry: () => ref.invalidate(invoicesProvider),
          data: (list) => list.isEmpty
              ? EmptyState(
                  title: context.t('Nothing owed'),
                  body: context.t(
                    'Commission is raised when a customer signs an '
                    'agreement, at your rate for that trade.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(Space.gutter),
                  itemCount: list.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: Space.sm),
                  itemBuilder: (context, i) => _InvoiceCard(view: list[i]),
                ),
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.view});

  final VendorInvoiceView view;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final (
      StatusTone tone,
      Color? amountColour,
    ) = switch (view.invoice.status) {
      // Ochre while it is simply due; iron once it is overdue, because that is
      // what can take a vendor out of the assignment pool.
      InvoiceStatus.pending => (StatusTone.waiting, palette.waiting),
      InvoiceStatus.overdue => (StatusTone.wrong, palette.wrong),
      InvoiceStatus.paid => (StatusTone.verified, null),
      InvoiceStatus.waived => (StatusTone.neutral, null),
      InvoiceStatus.cancelled => (StatusTone.neutral, null),
      InvoiceStatus.$unknown => (StatusTone.neutral, null),
    };

    return InterioBeeCard(
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  view.invoice.reference,
                  style: context.text.titleLarge,
                ),
              ),
              StatusPill(view.invoice.status.name, tone: tone),
            ],
          ),
          const SizedBox(height: Space.xs),
          MoneyText(Rupees(view.invoice.amount).formatted, tone: amountColour),
          const SizedBox(height: Space.xs),
          Text(
            context.t('Due {date} · {trades}', {
              'date': view.invoice.dueDate,
              'trades': view.domains.join(', '),
            }),
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performance = ref.watch(performanceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Performance'))),
      body: SafeArea(
        child: AsyncView(
          value: performance,
          onRetry: () => ref.invalidate(performanceProvider),
          data: (data) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            children: [
              SectionHead(
                context.t('By trade'),
                eyebrow: context.t('Rated separately'),
              ),
              Text(
                context.t(
                  'A good carpenter is not automatically a good painter, so '
                  'each trade is rated on its own — and leads are ranked by '
                  'your rating in the trade being browsed.',
                ),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.sm),
              for (final row in data.byDomain) ...[
                InterioBeeCard(
                  padding: const EdgeInsets.all(Space.cardPaddingWide),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              row.domain.name,
                              style: context.text.headlineSmall,
                            ),
                          ),
                          Text(
                            row.ratingCount == 0
                                ? context.t('Not yet rated')
                                : '${row.rating.toStringAsFixed(1)} ★',
                            style: context.text.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.xs),
                      Text(
                        context.t(
                          '{completed} completed · {won} won · {lost} lost · '
                          '{rate}% win rate',
                          {
                            'completed': row.completed,
                            'won': row.won,
                            'lost': row.lost,
                            'rate': row.winRatePercent.round(),
                          },
                        ),
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        context.t('Commission {percent}%', {
                          'percent': row.commissionPercent,
                        }),
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Space.xs),
              ],

              SectionHead(
                context.t('Overall'),
                eyebrow: context.t('Across every trade'),
              ),
              InterioBeeCard(
                padding: const EdgeInsets.all(Space.cardPaddingWide),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.t('Revenue'), style: context.text.labelMedium),
                    const SizedBox(height: Space.xxs),
                    MoneyText(Rupees(data.totalRevenue).formatted),
                    const SizedBox(height: Space.sm),
                    Text(
                      context.l10n.plural(
                        data.avgResponseHours.round(),
                        'Median response {n} hour',
                        'Median response {n} hours',
                      ),
                      style: context.text.bodyMedium,
                    ),
                  ],
                ),
              ),

              /// What the rating above is made of.
              ///
              /// The web puts these on `/partner/profile`; they sit here
              /// instead, beside the number they produce. A rating with no
              /// reviews under it is a score somebody cannot argue with or
              /// learn from.
              SectionHead(
                context.t('Reviews'),
                eyebrow: context.t('Left per job, per trade'),
              ),
              if (data.reviews.isEmpty)
                EmptyState(
                  title: context.t('No reviews yet'),
                  body: context.t(
                    'A customer leaves one per job, so each trade you deliver '
                    'is rated on its own.',
                  ),
                )
              else
                for (final entry in data.reviews) ...[
                  _ReviewCard(entry: entry),
                  const SizedBox(height: Space.xs),
                ],

              const SizedBox(height: Space.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

/// One customer's verdict, with the trade it was left for.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.entry});

  final VendorReview entry;

  @override
  Widget build(BuildContext context) {
    final review = entry.review;

    return InterioBeeCard(
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${review.rating} ★', style: context.text.titleLarge),
              const SizedBox(width: Space.xs),
              Expanded(
                child: Text(
                  // The customer's name as the API gives it. A vendor who has
                  // done the job knows who they are; nothing new is released
                  // here.
                  entry.clientName,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              StatusPill(entry.domain.name, tone: StatusTone.neutral),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: Space.xs),
            Text(review.comment, style: context.text.bodyMedium),
          ],

          /// The three sub-scores, when the customer gave them.
          ///
          /// They are optional on the contract and often absent, so the row
          /// appears only when there is something in it rather than as three
          /// dashes.
          if (review.qualityRating != null) ...[
            const SizedBox(height: Space.xs),
            Text(
              context.t(
                'Quality {quality}/5 · Timeliness {timeliness}/5 · '
                'Professionalism {professionalism}/5',
                {
                  'quality': review.qualityRating,
                  'timeliness': review.timelinessRating,
                  'professionalism': review.professionalismRating,
                },
              ),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// An empty portfolio is the most costly screen a vendor can have.
///
/// Customers compare three professionals on their photographs, so this says
/// what is missing and opens the camera rather than reporting a fact.
class _NothingPosted extends StatelessWidget {
  const _NothingPosted({required this.queue});

  final UploadQueue queue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Space.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('Nothing posted yet'),
            style: context.text.headlineSmall,
          ),
          const SizedBox(height: Space.xs),
          Text(
            context.t(
              'Photographs of finished jobs are the first thing a customer '
              'looks at, and they go on your profile as soon as you post them.',
            ),
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Space.md),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PostWorkScreen(queue: queue)),
            ),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(context.t('Post work')),
          ),
        ],
      ),
    );
  }
}

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key, required this.queue});

  /// Handed down so work can be posted from here — the photographs are on
  /// this phone, which is the whole reason this screen needed the button.
  final UploadQueue queue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('Portfolio')),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PostWorkScreen(queue: queue)),
            ),
            icon: const Icon(Icons.add_a_photo_outlined),
            tooltip: context.t('Post work'),
          ),
        ],
      ),
      body: SafeArea(
        child: AsyncView(
          value: portfolio,
          onRetry: () => ref.invalidate(portfolioProvider),
          data: (list) => list.isEmpty
              ? _NothingPosted(queue: queue)
              : ListView.separated(
                  padding: const EdgeInsets.all(Space.gutter),
                  itemCount: list.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: Space.sm),
                  itemBuilder: (context, i) {
                    final item = list[i];
                    return InterioBeeCard(
                      padding: const EdgeInsets.all(Space.cardPaddingWide),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: context.text.headlineSmall,
                                ),
                              ),
                              // Sage only when a person approved it. A pending
                              // item is not on the public profile.
                              StatusPill(
                                item.moderationStatus ==
                                        DomainApprovalStatus.rejected
                                    ? context.t('Taken down')
                                    : context.t('Live'),
                                tone:
                                    item.moderationStatus ==
                                        DomainApprovalStatus.rejected
                                    ? StatusTone.wrong
                                    : StatusTone.verified,
                              ),
                            ],
                          ),
                          const SizedBox(height: Space.xs),
                          Text(
                            item.description,
                            style: context.text.bodyMedium,
                          ),

                          /// The work itself.
                          ///
                          /// A portfolio without pictures is a list of job
                          /// titles, and a customer choosing between three
                          /// professionals has nothing to choose on.
                          if (item.media.isNotEmpty) ...[
                            const SizedBox(height: Space.sm),
                            MediaStrip(
                              items: [
                                for (final asset in item.media)
                                  MediaItem(
                                    url: asset.url,
                                    caption: asset.caption ?? item.title,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
