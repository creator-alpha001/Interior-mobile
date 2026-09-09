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

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';
import 'quote_comparison.dart';
import 'review_screen.dart';

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
                  Text(
                    context.t('Your jobs'),
                    style: context.text.headlineLarge,
                  ),
                  const Spacer(),
                  if (onStartNew != null)
                    FilledButton(
                      onPressed: onStartNew,
                      child: Text(context.t('New')),
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
                    ? EmptyState(
                        title: context.t('Nothing yet'),
                        body: context.t(
                          'Tell us what you need and we will find you three '
                          'verified professionals.',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(requirementsProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.gutter,
                            vertical: Space.xs,
                          ),
                          itemCount: list.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: Space.md),
                          itemBuilder: (context, i) =>
                              RequirementCard(lead: list[i]),
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
    return InterioBeeCard(
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lead.lead.reference,
                  style: context.text.titleMedium,
                ),
              ),
              Text(
                lead.city.name,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
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
          const InterioBeeDivider(inset: 0),
          const SizedBox(height: Space.sm),

          // One card per service. Each has its own everything.
          for (final service in lead.domains) ...[
            ServiceRow(service: service, requirementId: lead.lead.id),

            /// Visits for this service, with the one thing a customer can do
            /// about them. The web can ask to move a visit and the app could
            /// not — `requestReschedule` was unreachable.
            ///
            /// **Indented, and labelled.** These used to sit at the service
            /// row's own width, so a card reading "Yadav Furniture Works ·
            /// 26 Aug" looked like a peer of "Furniture Work · 3 quotes" —
            /// two visits between two services read as four things at the same
            /// level, and the screen became a wall of similar grey boxes. They
            /// belong *to* the service above them, and now look it.
            if (service.meetings.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: Space.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Space.xs),
                    Text(
                      context.t('Visits').toUpperCase(),
                      style: InterioBeeTextStyles.eyebrow.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      semanticsLabel: context.t('Visits'),
                    ),
                    for (final meeting in service.meetings)
                      VisitRow(meeting: meeting, trade: service.domain.name),
                  ],
                ),
              ),

            const SizedBox(height: Space.sm),
          ],

          if (lead.isMultiDomain) ...[
            const SizedBox(height: Space.xxs),
            Text(
              context.t(
                'Each job is quoted and scheduled separately, even where the same '
                'professional does more than one.',
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

/// One visit, and the request to move it.
///
/// Confirming a visit is what releases the customer's address to that
/// professional — per service, not per customer — so this row is also where
/// somebody learns that has happened.
class VisitRow extends ConsumerWidget {
  const VisitRow({super.key, required this.meeting, required this.trade});

  final MeetingView meeting;
  final String trade;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asked = meeting.meeting.rescheduleRequestedAt != null;
    final settled =
        meeting.meeting.status == MeetingStatus.completed ||
        meeting.meeting.status == MeetingStatus.noShow;

    return Padding(
      padding: const EdgeInsets.only(top: Space.xxs),
      child: InterioBeeCard(
        nested: true,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting.professional.companyName,
                    style: context.text.titleMedium,
                  ),
                  Text(
                    // The API's ISO-8601, not the customer's. "2026-08-26
                    // 15:30:00+05:30" is a machine's idea of a Wednesday
                    // afternoon. Same helper the vendor's visits use.
                    formatWhen(context, meeting.meeting.scheduledAt),
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (asked)
              // Ochre: it is with us now, not with them.
              StatusPill(context.t('Move requested'), tone: StatusTone.waiting)
            else if (!settled)
              TextButton(
                onPressed: () => showRescheduleSheet(
                  context,
                  ref,
                  meetingId: meeting.meeting.id,
                ),
                child: Text(context.t('Move it')),
              ),
          ],
        ),
      ),
    );
  }
}

class ServiceRow extends StatelessWidget {
  const ServiceRow({
    super.key,
    required this.service,
    required this.requirementId,
  });

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
                      _statusLine(context, service),
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
                Icon(
                  Icons.chevron_right,
                  color: context.colors.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Takes a context so it can translate.
  ///
  /// The counts are placeholders rather than interpolations because the number
  /// does not sit in the same position in Hindi, and a singular is a different
  /// sentence rather than the same one with an `s` removed.
  static String _statusLine(BuildContext context, LeadDomainView service) {
    if (service.leadDomain.selectedQuoteId != null) {
      final chosen = service.selectedProfessional?.companyName;
      return chosen == null
          ? context.t('You chose a professional')
          : context.t('You chose {name}', {'name': chosen});
    }
    if (service.quotes.isNotEmpty) {
      return context.l10n.plural(
        service.quotes.length,
        context.t('{n} quote ready to compare'),
        context.t('{n} quotes ready to compare'),
      );
    }
    if (service.assignments.isNotEmpty) {
      return context.l10n.plural(
        service.assignments.length,
        context.t('{n} professional invited to quote'),
        context.t('{n} professionals invited to quote'),
      );
    }
    return context.t('We are finding professionals for this');
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.service});

  final LeadDomainView service;

  @override
  Widget build(BuildContext context) {
    return switch (service.leadDomain.status) {
      LeadDomainStatus.completed => StatusPill(
        context.t('Done'),
        tone: StatusTone.verified,
      ),
      LeadDomainStatus.inProgress => StatusPill(
        context.t('In progress'),
        tone: StatusTone.neutral,
      ),
      LeadDomainStatus.vendorSelected => StatusPill(
        context.t('Chosen'),
        tone: StatusTone.verified,
      ),
      LeadDomainStatus.quoted => StatusPill(
        context.t('Your turn'),
        tone: StatusTone.yours,
      ),
      LeadDomainStatus.cancelled => StatusPill(
        context.t('Cancelled'),
        tone: StatusTone.wrong,
      ),
      // Waiting on us, not on them.
      _ => StatusPill(context.t('With us'), tone: StatusTone.waiting),
    };
  }
}
