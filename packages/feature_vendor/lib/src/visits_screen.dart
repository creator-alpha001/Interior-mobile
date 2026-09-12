/// Site visits, and the address release that hangs off them.
///
/// MOBILE.md §6.2: *"The address-release state is a first-class UI state:
/// locality only until the visit for that service is confirmed, then the full
/// address with a maps launcher. Two distinct designs, not one with an empty
/// line."*
///
/// Two designs is the point. A sealed visit is not a released one with a
/// missing field — it is a different situation, and rendering it as a blank
/// line reads like a bug in the app rather than a rule of the platform. The
/// vendor should understand that confirming the visit is what unlocks the
/// address, because that is the actual mechanism: the server computes release
/// per service, beside the query.
///
/// **There is no dialer here, and there never will be.** MOBILE.md §7.6 asks
/// for a grep test over `tel:` and `url_launcher` in this package — but the
/// same document asks for a maps launcher, which needs `url_launcher`. The test
/// in `test/boundaries_test.dart` therefore bans the *schemes* that carry the
/// risk (`tel:`, `sms:`, `whatsapp:`) rather than the package, and separately
/// asserts that every `launchUrl` here is a map.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'async_view.dart';
import 'providers.dart';
import 'where_client_is.dart';

class VisitsScreen extends ConsumerWidget {
  const VisitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visits = ref.watch(visitsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Space.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              child: Text(
                context.t('Visits'),
                style: context.text.headlineLarge,
              ),
            ),
            const SizedBox(height: Space.sm),
            Expanded(
              child: AsyncView(
                value: visits,
                onRetry: () => ref.invalidate(visitsProvider),
                data: (list) {
                  if (list.isEmpty) {
                    return EmptyState(
                      title: context.t('No visits booked'),
                      body: context.t(
                        'The coordinator arranges site visits with both '
                        'sides and confirms the slot. Nothing to travel to '
                        'yet.',
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(visitsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.gutter,
                        vertical: Space.xs,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: Space.sm),
                      itemBuilder: (context, i) => VisitCard(visit: list[i]),
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

class VisitCard extends StatelessWidget {
  const VisitCard({super.key, required this.visit});

  final VendorVisitView visit;

  /// The whole distinction, in one line.
  ///
  /// Computed server-side per service and sent as a null, not inferred here
  /// from the visit's status — the same customer can be sealed on one service
  /// and released on another, and that is correct.
  bool get _addressReleased => visit.client.address != null;

  @override
  Widget build(BuildContext context) {
    return InterioBeeCard(
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
                    Text(
                      visit.client.displayName,
                      style: context.text.headlineSmall,
                    ),
                    const SizedBox(height: Space.xxs),
                    Text(
                      visit.leadReference,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _VisitStatus(status: visit.meeting.status),
            ],
          ),

          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.xxs,
            children: [
              StatusPill(visit.domain.name, tone: StatusTone.neutral),
              StatusPill(
                _typeLabel(context, visit.meeting.type),
                tone: StatusTone.neutral,
              ),
            ],
          ),

          const SizedBox(height: Space.sm),
          Text(
            formatWhen(context, visit.meeting.scheduledAt),
            style: context.text.titleLarge,
          ),

          const SizedBox(height: Space.sm),
          const InterioBeeDivider(inset: 0),
          const SizedBox(height: Space.sm),

          // The two designs.
          if (_addressReleased)
            _ReleasedAddress(visit: visit)
          else
            _SealedAddress(visit: visit),

          if (visit.meeting.notes != null) ...[
            const SizedBox(height: Space.sm),
            Text(visit.meeting.notes!, style: context.text.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Confirmed: the full address, and a way to get there.
class _ReleasedAddress extends StatelessWidget {
  const _ReleasedAddress({required this.visit});

  final VendorVisitView visit;

  Future<void> _openMap(BuildContext context) async {
    final address = visit.client.address!;
    // A maps query, and nothing else. There is deliberately no `tel:` anywhere
    // in this package — see the note at the top of this file.
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('Could not open maps on this device.')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.place_outlined,
              size: TapTarget.glyph,
              // Sage: a person confirmed this visit, which is what released it.
              color: context.palette.verified,
            ),
            const SizedBox(width: Space.xxs),
            Text(
              context.t('Address released'),
              style: context.text.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: Space.xs),
        Text(visit.client.address!, style: context.text.bodyLarge),
        const SizedBox(height: Space.sm),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _openMap(context),
              icon: const Icon(Icons.map_outlined, size: TapTarget.glyph),
              label: Text(context.t('Directions')),
            ),
            const SizedBox(width: Space.xs),
            OutlinedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: visit.client.address!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.t('Address copied'))),
                );
              },
              child: Text(context.t('Copy')),
            ),
          ],
        ),
      ],
    );
  }
}

/// Not yet confirmed: the locality, and why that is all there is.
class _SealedAddress extends StatelessWidget {
  const _SealedAddress({required this.visit});

  final VendorVisitView visit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Space.cardPadding),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: Radii.smallRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                size: TapTarget.glyph,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: Space.xxs),
              Text(
                context.t('Address not released yet'),
                style: context.text.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(whereClientIs(visit.client), style: context.text.titleLarge),
          const SizedBox(height: Space.xxs),
          Text(
            // Explains the mechanism, so it reads as a rule rather than a bug.
            context.t(
              'The full address is released once the coordinator confirms this '
              'visit with both sides. It is released per service, so confirming '
              'one job does not unlock another.',
            ),
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitStatus extends StatelessWidget {
  const _VisitStatus({required this.status});

  final MeetingStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      MeetingStatus.confirmed => StatusPill(
        context.t('Confirmed'),
        tone: StatusTone.verified,
      ),
      MeetingStatus.scheduled => StatusPill(
        context.t('Awaiting confirmation'),
        tone: StatusTone.waiting,
      ),
      MeetingStatus.rescheduled => StatusPill(
        context.t('Rescheduling'),
        tone: StatusTone.waiting,
      ),
      MeetingStatus.completed => StatusPill(
        context.t('Done'),
        tone: StatusTone.verified,
      ),
      MeetingStatus.noShow => StatusPill(
        context.t('No show'),
        tone: StatusTone.wrong,
      ),
      MeetingStatus.$unknown => StatusPill(
        context.t('Unknown'),
        tone: StatusTone.neutral,
      ),
    };
  }
}

String _typeLabel(BuildContext context, MeetingType type) => switch (type) {
  MeetingType.consultation => context.t('Consultation'),
  MeetingType.siteVisit => context.t('Site visit'),
  MeetingType.measurement => context.t('Measurement'),
  MeetingType.handover => context.t('Handover'),
  MeetingType.$unknown => context.t('Visit'),
};
