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

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, this.onSignOut});

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
              title: context.t('Portfolio'),
              subtitle: context.t('Approved work on your public profile'),
              onTap: () => _push(context, const PortfolioScreen()),
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
    return AanganCard(
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

    return AanganCard(
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
            'Due ${view.invoice.dueDate} · ${view.domains.join(", ")}',
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
                'A good carpenter is not automatically a good painter, so each '
                'trade is rated on its own — and leads are ranked by your '
                'rating in the trade being browsed.',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.sm),
              for (final row in data.byDomain) ...[
                AanganCard(
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
                        '${row.completed} completed · ${row.won} won · '
                        '${row.lost} lost · ${row.winRatePercent.round()}% win rate',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Commission ${row.commissionPercent}%',
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
              AanganCard(
                padding: const EdgeInsets.all(Space.cardPaddingWide),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Revenue', style: context.text.labelMedium),
                    const SizedBox(height: Space.xxs),
                    MoneyText(Rupees(data.totalRevenue).formatted),
                    const SizedBox(height: Space.sm),
                    Text(
                      'Median response ${data.avgResponseHours} hours',
                      style: context.text.bodyMedium,
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

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Portfolio'))),
      body: SafeArea(
        child: AsyncView(
          value: portfolio,
          onRetry: () => ref.invalidate(portfolioProvider),
          data: (list) => list.isEmpty
              ? EmptyState(
                  title: context.t('Nothing published'),
                  body: context.t(
                    'Portfolio work is moderated before it appears on your '
                    'public profile.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(Space.gutter),
                  itemCount: list.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: Space.sm),
                  itemBuilder: (context, i) {
                    final item = list[i];
                    return AanganCard(
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
                                item.moderationStatus.name,
                                tone:
                                    item.moderationStatus ==
                                        DomainApprovalStatus.approved
                                    ? StatusTone.verified
                                    : StatusTone.waiting,
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
