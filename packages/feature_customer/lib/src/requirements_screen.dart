/// Requirements, and the services inside them.
///
/// MOBILE.md §6.1: *"A requirement is **N service tracks**, not one thing. The
/// detail screen is a stack of per-domain cards, each with its own status,
/// quotes, visits and unread count."*
///
/// That is not a layout preference. Assignment, quoting, visits, agreements and
/// execution all hang off the service rather than the requirement, so a screen
/// that shows one status for the whole thing would be inventing a number the
/// platform does not have.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';
import 'quote_comparison.dart';

class RequirementsScreen extends ConsumerWidget {
  const RequirementsScreen({super.key, this.onStartNew});

  final VoidCallback? onStartNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requirements = ref.watch(requirementsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Space.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              child: Row(
                children: [
                  Text('Your jobs', style: context.text.headlineLarge),
                  const Spacer(),
                  if (onStartNew != null)
                    FilledButton(
                      onPressed: onStartNew,
                      child: const Text('New'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
            Expanded(
              child: AsyncView(
                value: requirements,
                onRetry: () => ref.invalidate(requirementsProvider),
                data: (list) => list.isEmpty
                    ? const EmptyState(
                        title: 'Nothing yet',
                        body: 'Tell us what you need and we will find you three '
                            'verified professionals.',
                      )
                    : RefreshIndicator(
                        onRefresh: () async => ref.invalidate(requirementsProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.gutter,
                            vertical: Space.xs,
                          ),
                          itemCount: list.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: Space.md),
                          itemBuilder: (context, i) => RequirementCard(lead: list[i]),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequirementCard extends StatelessWidget {
  const RequirementCard({super.key, required this.lead});

  final LeadView lead;

  @override
  Widget build(BuildContext context) {
    return AanganCard(
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(lead.lead.reference, style: context.text.titleMedium),
              ),
              Text(
                lead.city.name,
                style: context.text.bodySmall
                    ?.copyWith(color: context.colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(
            lead.lead.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyMedium,
          ),

          const SizedBox(height: Space.md),
          const AanganDivider(inset: 0),
          const SizedBox(height: Space.sm),

          // One card per service. Each has its own everything.
          for (final service in lead.domains) ...[
            ServiceRow(service: service, requirementId: lead.lead.id),
            const SizedBox(height: Space.xs),
          ],

          if (lead.isMultiDomain) ...[
            const SizedBox(height: Space.xxs),
            Text(
              'Each job is quoted and scheduled separately, even where the same '
              'professional does more than one.',
              style: context.text.bodySmall
                  ?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class ServiceRow extends StatelessWidget {
  const ServiceRow({super.key, required this.service, required this.requirementId});

  final LeadDomainView service;
  final String requirementId;

  @override
  Widget build(BuildContext context) {
    final quotes = service.quotes.length;
    final chosen = service.leadDomain.selectedQuoteId != null;
    final waitingOnYou = quotes > 0 && !chosen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: quotes == 0
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuoteComparisonScreen(
                      service: service,
                      requirementId: requirementId,
                    ),
                  ),
                ),
        borderRadius: Radii.smallRadius,
        child: Container(
          padding: const EdgeInsets.all(Space.cardPadding),
          decoration: BoxDecoration(
            // The peach panel, but only when the customer is genuinely the
            // blocker. Everywhere else it would stop meaning anything.
            color: waitingOnYou
                ? context.colors.primaryContainer
                : context.colors.surfaceContainer,
            borderRadius: Radii.smallRadius,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.domain.name, style: context.text.titleLarge),
                    const SizedBox(height: Space.xxs),
                    Text(
                      _statusLine(service),
                      style: context.text.bodySmall?.copyWith(
                        color: waitingOnYou
                            ? context.colors.onPrimaryContainer
                            : context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (service.unreadMessages > 0)
                StatusPill('${service.unreadMessages}', tone: StatusTone.yours)
              else
                _StatusPill(service: service),
              if (quotes > 0)
                Icon(Icons.chevron_right, color: context.colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusLine(LeadDomainView service) {
    if (service.leadDomain.selectedQuoteId != null) {
      return 'You chose ${service.selectedProfessional?.companyName ?? "a professional"}';
    }
    if (service.quotes.isNotEmpty) {
      return '${service.quotes.length} quotes ready to compare';
    }
    if (service.assignments.isNotEmpty) {
      return '${service.assignments.length} professionals invited to quote';
    }
    return 'We are finding professionals for this';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.service});

  final LeadDomainView service;

  @override
  Widget build(BuildContext context) {
    return switch (service.leadDomain.status) {
      LeadDomainStatus.completed =>
        const StatusPill('Done', tone: StatusTone.verified),
      LeadDomainStatus.inProgress =>
        const StatusPill('In progress', tone: StatusTone.neutral),
      LeadDomainStatus.vendorSelected =>
        const StatusPill('Chosen', tone: StatusTone.verified),
      LeadDomainStatus.quoted =>
        const StatusPill('Your turn', tone: StatusTone.yours),
      LeadDomainStatus.cancelled =>
        const StatusPill('Cancelled', tone: StatusTone.wrong),
      // Waiting on us, not on them.
      _ => const StatusPill('With us', tone: StatusTone.waiting),
    };
  }
}
