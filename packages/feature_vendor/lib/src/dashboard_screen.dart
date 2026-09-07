/// The dashboard: what needs doing, in numbers.
///
/// The prototype's figures block, dense and tabular. Two things it does that a
/// generic counter grid would not:
///
///   - **Commission is here and nowhere near a customer.** These figures exist
///     only on this side of the platform, and the vendor's own margin is theirs
///     to see. `MaskedClientSummary` is what makes the reverse impossible.
///   - **Ratings are per trade.** A vendor excellent at painting and average at
///     carpentry is shown as exactly that, because that is how they are ranked
///     and how leads reach them.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, this.onOpenLeads});

  final void Function(LeadFilter filter)? onOpenLeads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      body: SafeArea(
        child: AsyncView(
          value: dashboard,
          onRetry: () => ref.invalidate(dashboardProvider),
          data: (data) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardProvider),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              children: [
                const SizedBox(height: Space.xl),
                Text(data.displayName, style: context.text.displayLarge),
                const SizedBox(height: Space.xxs),
                Wrap(
                  spacing: Space.xxs,
                  runSpacing: Space.xxs,
                  children: [
                    for (final link in data.domains)
                      StatusPill(link.domain.name, tone: StatusTone.neutral),
                  ],
                ),

                if (data.newLeads > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: Space.lg),
                    child: ActionRequired(
                      title: data.newLeads == 1
                          ? 'One new lead'
                          : '${data.newLeads} new leads',
                      body: 'The first quote in often wins. These are waiting '
                          'on you.',
                      action: FilledButton(
                        onPressed: () => onOpenLeads?.call(LeadFilter.valueNew),
                        child: const Text('Open leads'),
                      ),
                    ),
                  ),

                const SectionHead('Your pipeline', eyebrow: 'Right now'),
                _Figures(
                  rows: [
                    ('New', data.newLeads, StatusTone.yours),
                    ('Awaiting your quote', data.awaitingQuote, StatusTone.yours),
                    ('Quotes out', data.quotesOut, StatusTone.waiting),
                    ('Won this period', data.wonThisPeriod, StatusTone.verified),
                  ],
                ),

                const SectionHead('Work in hand', eyebrow: 'Live'),
                _Figures(
                  rows: [
                    ('Live projects', data.liveProjects, StatusTone.neutral),
                    ('Visits today', data.visitsToday, StatusTone.neutral),
                    ('Unread messages', data.unreadMessages, StatusTone.neutral),
                  ],
                ),

                const SectionHead('Commission', eyebrow: 'Yours alone'),
                AanganCard(
                  padding: const EdgeInsets.all(Space.cardPaddingWide),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Due', style: context.text.labelMedium),
                                const SizedBox(height: Space.xxs),
                                MoneyText(
                                  Rupees(data.commissionDue).formatted,
                                  // Ochre: waiting on you to pay, not wrong yet.
                                  tone: data.commissionDue > 0
                                      ? context.palette.waiting
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Overdue', style: context.text.labelMedium),
                                const SizedBox(height: Space.xxs),
                                MoneyText(
                                  Rupees(data.commissionOverdue).formatted,
                                  tone: data.commissionOverdue > 0
                                      ? context.palette.wrong
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (data.commissionOverdue > 0) ...[
                        const SizedBox(height: Space.sm),
                        Text(
                          'Overdue commission can suspend new lead assignment. '
                          'Settle it to stay in the pool.',
                          style: context.text.bodySmall
                              ?.copyWith(color: context.palette.wrong),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Space.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A dense block of counters, in the prototype's rhythm.
class _Figures extends StatelessWidget {
  const _Figures({required this.rows});

  final List<(String, num, StatusTone)> rows;

  @override
  Widget build(BuildContext context) {
    return AanganCard(
      padding: const EdgeInsets.symmetric(vertical: Space.xs),
      child: Column(
        children: [
          for (final (index, row) in rows.indexed) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.cardPadding,
                vertical: Space.xs,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(row.$1, style: context.text.titleMedium)),
                  Text(
                    '${row.$2}',
                    // Tabular, so a column of counters does not jitter.
                    style: AanganTextStyles.financialNum.copyWith(
                      fontSize: 20,
                      color: row.$2 == 0
                          ? context.colors.onSurfaceVariant
                          : AanganColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (index < rows.length - 1) const AanganDivider(),
          ],
        ],
      ),
    );
  }
}
