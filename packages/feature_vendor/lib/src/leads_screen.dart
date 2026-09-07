/// The leads a professional has been offered.
///
/// Every card shows a `MaskedClientSummary`: a display name, a locality, and no
/// field capable of carrying a phone number or an email. That is structural
/// rather than a rendering choice — the type has nowhere to put one — and it is
/// the platform's whole proposition. If a vendor can reach the customer
/// directly, the relationship and the commission go with them, and the customer
/// loses the person they can complain to.
///
/// `competingQuotes` is shown plainly and never softened. Nobody should assume
/// the job is theirs.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';

class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key, this.onOpen});

  final void Function(VendorLeadCard lead)? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(leadFilterProvider);
    final leads = ref.watch(leadsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: Space.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              child: Row(
                children: [
                  Text('Leads', style: context.text.headlineLarge),
                  const Spacer(),
                  leads.maybeWhen(
                    data: (list) => Text(
                      '${list.length}',
                      style: context.text.titleMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
                children: [
                  for (final entry in leadFilterLabels.entries) ...[
                    _FilterChip(
                      label: entry.value,
                      selected: filter == entry.key,
                      onTap: () => ref.read(leadFilterProvider.notifier).state = entry.key,
                    ),
                    const SizedBox(width: Space.xs),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
            Expanded(
              child: AsyncView(
                value: leads,
                onRetry: () => ref.invalidate(leadsProvider),
                data: (list) {
                  if (list.isEmpty) {
                    return EmptyState(
                      title: 'Nothing here',
                      body: switch (filter) {
                        LeadFilter.valueNew =>
                          'No new leads right now. Assignment is manual — our '
                              'team rings you before offering one.',
                        LeadFilter.quoting => 'No quotes outstanding.',
                        LeadFilter.won => 'No won jobs in this period yet.',
                        LeadFilter.lost => 'Nothing lost. Good.',
                        _ => 'No leads have been offered to you yet.',
                      },
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(leadsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.gutter,
                        vertical: Space.xs,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const SizedBox(height: Space.sm),
                      itemBuilder: (context, i) => LeadCard(
                        lead: list[i],
                        onTap: () => onOpen?.call(list[i]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.smallRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Space.sm),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // A tab, not a status. So a 4px radius, not a pill: the pill is
            // reserved for metadata and using it here would blunt that signal.
            borderRadius: Radii.smallRadius,
            color: selected ? AanganColors.ink : Colors.transparent,
            border: Border.all(
              color: selected ? AanganColors.ink : context.palette.inputBorder,
            ),
          ),
          child: Text(
            label,
            style: context.text.titleMedium?.copyWith(
              color: selected ? AanganColors.limestone : AanganColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class LeadCard extends StatelessWidget {
  const LeadCard({super.key, required this.lead, this.onTap});

  final VendorLeadCard lead;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AanganCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First name and initial. There is no other name to show.
                    Text(lead.client.displayName, style: context.text.headlineSmall),
                    const SizedBox(height: Space.xxs),
                    Text(
                      '${lead.client.locality} · ${lead.client.city.name}',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _LeadStatus(lead: lead),
            ],
          ),

          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.xxs,
            runSpacing: Space.xxs,
            children: [
              StatusPill(lead.domain.name, tone: StatusTone.neutral),
              StatusPill(_urgencyLabel(lead.urgency), tone: _urgencyTone(lead.urgency)),
              StatusPill(_materialLabel(lead.materialSource), tone: StatusTone.neutral),
            ],
          ),

          const SizedBox(height: Space.sm),
          Text(
            lead.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyMedium,
          ),

          const SizedBox(height: Space.sm),
          const AanganDivider(inset: 0),
          const SizedBox(height: Space.sm),

          Row(
            children: [
              if (lead.budgetMax != null) ...[
                Text('Ceiling ', style: context.text.bodySmall),
                Text(
                  Rupees(lead.budgetMax!).short,
                  style: context.text.titleMedium,
                ),
              ] else
                Text(
                  'No budget stated',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              const Spacer(),
              // Stated plainly. Softening this is how a vendor assumes the job
              // is theirs and prices it lazily.
              Text(
                lead.competingQuotes == 0
                    ? 'First to quote'
                    : '${lead.competingQuotes} others quoting',
                style: context.text.bodySmall?.copyWith(
                  color: lead.competingQuotes > 2
                      ? palette.waiting
                      : context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeadStatus extends StatelessWidget {
  const _LeadStatus({required this.lead});

  final VendorLeadCard lead;

  @override
  Widget build(BuildContext context) {
    // Decided server-side. A screen comparing ids against a hardcoded "who am
    // I" is a bug waiting for the day that value is wrong.
    if (lead.won) return const StatusPill('Won', tone: StatusTone.verified);
    if (lead.lost) return const StatusPill('Lost', tone: StatusTone.wrong);
    if (lead.myQuote != null) {
      return const StatusPill('Quoted', tone: StatusTone.waiting);
    }
    if (lead.unreadMessages > 0) {
      return StatusPill('${lead.unreadMessages} unread', tone: StatusTone.yours);
    }
    return const StatusPill('Your turn', tone: StatusTone.yours);
  }
}

String _urgencyLabel(String urgency) => switch (urgency) {
      'immediate' => 'Immediate',
      'within_month' => 'Within a month',
      'exploring' => 'Exploring',
      _ => urgency,
    };

StatusTone _urgencyTone(String urgency) =>
    urgency == 'immediate' ? StatusTone.yours : StatusTone.neutral;

String _materialLabel(MaterialSource source) => switch (source) {
      MaterialSource.vendorSupplied => 'You supply material',
      MaterialSource.customerSupplied => 'Customer supplies material',
      MaterialSource.undecided => 'Material undecided',
      MaterialSource.$unknown => 'Material unknown',
    };
