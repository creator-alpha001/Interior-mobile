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

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    this.onOpenLeads,
    this.onOpenVisits,
    this.onOpenProjects,
    this.onPostWork,
  });

  final void Function(LeadFilter filter)? onOpenLeads;

  /// The shell owns the tab index, so switching tabs is its job rather than
  /// this screen's. Posting work opens a screen and is pushed instead.
  final VoidCallback? onOpenVisits;
  final VoidCallback? onOpenProjects;
  final VoidCallback? onPostWork;

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
                const SizedBox(height: Space.md),

                /// The mark, so the vendor side looks like the same product
                /// as the customer side and the website.
                Row(
                  children: [
                    const DecoraShineLogo(height: 26),
                    const Spacer(),
                    if (data.professional.verificationStatus ==
                        VerificationStatus.verified)
                      StatusPill(
                        context.t('Verified'),
                        tone: StatusTone.verified,
                      ),
                  ],
                ),
                const SizedBox(height: Space.lg),
                Text(data.displayName, style: context.text.headlineLarge),
                const SizedBox(height: Space.xxs),
                Wrap(
                  spacing: Space.xxs,
                  runSpacing: Space.xxs,
                  children: [
                    for (final link in data.domains)
                      StatusPill(link.domain.name, tone: StatusTone.neutral),
                  ],
                ),

                /// **Four things, where a thumb can reach them.**
                ///
                /// This screen was a column of counters: true, and nothing to
                /// do. The work a vendor opens the app for — answer a lead,
                /// check today's visits, look at a running job, post the
                /// photographs they just took — took two taps through a tab
                /// bar and a list. Now it is one, above the numbers.
                const SizedBox(height: Space.lg),
                _QuickActions(
                  newLeads: data.newLeads,
                  visitsToday: data.visitsToday,
                  liveProjects: data.liveProjects,
                  onOpenLeads: onOpenLeads == null
                      ? null
                      : () => onOpenLeads!(LeadFilter.valueNew),
                  onOpenVisits: onOpenVisits,
                  onOpenProjects: onOpenProjects,
                  onPostWork: onPostWork,
                ),

                if (data.newLeads > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: Space.lg),
                    child: ActionRequired(
                      title: context.l10n.plural(
                        data.newLeads,
                        context.t('One new lead'),
                        context.t('{n} new leads'),
                      ),
                      body: context.t(
                        'The first quote in often wins. These are waiting '
                        'on you.',
                      ),
                      action: FilledButton(
                        onPressed: () => onOpenLeads?.call(LeadFilter.valueNew),
                        child: Text(context.t('Open leads')),
                      ),
                    ),
                  ),

                SectionHead(
                  context.t('Your pipeline'),
                  eyebrow: context.t('Right now'),
                ),
                _Figures(
                  rows: [
                    (context.t('New'), data.newLeads, StatusTone.yours),
                    (
                      context.t('Awaiting your quote'),
                      data.awaitingQuote,
                      StatusTone.yours,
                    ),
                    (
                      context.t('Quotes out'),
                      data.quotesOut,
                      StatusTone.waiting,
                    ),
                    (
                      context.t('Won this period'),
                      data.wonThisPeriod,
                      StatusTone.verified,
                    ),
                  ],
                ),

                SectionHead(
                  context.t('Work in hand'),
                  eyebrow: context.t('Live'),
                ),
                _Figures(
                  rows: [
                    (
                      context.t('Live projects'),
                      data.liveProjects,
                      StatusTone.neutral,
                    ),
                    (
                      context.t('Visits today'),
                      data.visitsToday,
                      StatusTone.neutral,
                    ),
                    (
                      context.t('Unread messages'),
                      data.unreadMessages,
                      StatusTone.neutral,
                    ),
                  ],
                ),

                /// Commission appears on no customer surface at all — not
                /// because a screen hides it, but because no customer-facing
                /// response carries the figure.
                SectionHead(
                  context.t('Commission'),
                  eyebrow: context.t('Yours alone'),
                ),
                InterioBeeCard(
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
                                Text(
                                  context.t('Overdue'),
                                  style: context.text.labelMedium,
                                ),
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
                          context.t(
                            'Overdue commission can suspend new lead assignment. '
                            'Settle it to stay in the pool.',
                          ),
                          style: context.text.bodySmall?.copyWith(
                            color: context.palette.wrong,
                          ),
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
    return InterioBeeCard(
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
                  Expanded(
                    child: Text(row.$1, style: context.text.titleMedium),
                  ),
                  Text(
                    '${row.$2}',
                    // Tabular, so a column of counters does not jitter.
                    style: InterioBeeTextStyles.financialNum.copyWith(
                      fontSize: 20,
                      color: row.$2 == 0
                          ? context.colors.onSurfaceVariant
                          : InterioBeeColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (index < rows.length - 1) const InterioBeeDivider(),
          ],
        ],
      ),
    );
  }
}

/// The four things a vendor opens the app to do.
///
/// Counts on the tiles, because "3 new" is the reason to press it and a bare
/// label makes somebody press it to find out.
class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.newLeads,
    required this.visitsToday,
    required this.liveProjects,
    required this.onOpenLeads,
    required this.onOpenVisits,
    required this.onOpenProjects,
    required this.onPostWork,
  });

  final int newLeads;
  final int visitsToday;
  final int liveProjects;
  final VoidCallback? onOpenLeads;
  final VoidCallback? onOpenVisits;
  final VoidCallback? onOpenProjects;
  final VoidCallback? onPostWork;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Action(
          icon: Icons.inbox_outlined,
          label: context.t('Leads'),
          count: newLeads,
          // Terracotta: a new lead is the one thing on this screen that is
          // genuinely the vendor's turn.
          tone: newLeads > 0 ? StatusTone.yours : StatusTone.neutral,
          onTap: onOpenLeads,
        ),
        const SizedBox(width: Space.xs),
        _Action(
          icon: Icons.event_outlined,
          label: context.t('Visits'),
          count: visitsToday,
          tone: StatusTone.neutral,
          onTap: onOpenVisits,
        ),
        const SizedBox(width: Space.xs),
        _Action(
          icon: Icons.construction_outlined,
          label: context.t('Jobs'),
          count: liveProjects,
          tone: StatusTone.neutral,
          onTap: onOpenProjects,
        ),
        const SizedBox(width: Space.xs),
        _Action(
          icon: Icons.add_a_photo_outlined,
          label: context.t('Post work'),
          count: null,
          tone: StatusTone.neutral,
          onTap: onPostWork,
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.count,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String label;

  /// Null on an action that nothing is waiting behind.
  final int? count;
  final StatusTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final highlight = tone == StatusTone.yours;

    return Expanded(
      child: InterioBeeCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          vertical: Space.sm,
          horizontal: Space.xs,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: TapTarget.glyph,
              color: highlight
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: Space.xxs),
            Text(
              count == null ? '' : '$count',
              style: InterioBeeTextStyles.financialNum.copyWith(
                fontSize: 18,
                color: highlight
                    ? context.colors.primary
                    : (count ?? 0) == 0
                    ? context.colors.onSurfaceVariant
                    : InterioBeeColors.ink,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
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
