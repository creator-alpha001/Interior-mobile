/// One lead, in full.
///
/// Two things this screen weights deliberately:
///
///   **The brief outranks the description.** `description` is the customer's
///   own words, typed into a form. `brief` is what ops captured on the call,
///   and MOBILE.md §6.2 says plainly that the brief is the real scope. So the
///   brief is given the space and the description is offered as context.
///
///   **There is no way to contact the customer.** No number, no dialer, no
///   "message the client". The only thread is with Aangan, and the platform
///   carries what matters across. That is the proposition, not a limitation.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'async_view.dart';
import 'providers.dart';
import 'quote_builder.dart';

class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({
    super.key,
    required this.leadDomainId,
    this.onOpenThread,
  });

  final String leadDomainId;
  final void Function(VendorLeadCard lead)? onOpenThread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lead = ref.watch(leadProvider(leadDomainId));

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Lead'))),
      body: SafeArea(
        child: AsyncView(
          value: lead,
          onRetry: () => ref.invalidate(leadProvider(leadDomainId)),
          data: (data) => _Detail(lead: data, onOpenThread: onOpenThread),
        ),
      ),
    );
  }
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.lead, this.onOpenThread});

  final VendorLeadCard lead;
  final void Function(VendorLeadCard lead)? onOpenThread;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  bool _busy = false;

  Future<void> _respond(bool accept) async {
    final reason = accept ? null : await _askReason();
    if (!accept && reason == null) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(vendorApiProvider)
          .vendor
          .respondToLead(
            id: widget.lead.leadDomain.id,
            body: RespondToLeadBody(
              response: accept
                  ? RespondToLeadBodyResponse.accepted
                  : RespondToLeadBodyResponse.rejected,
              reason: reason,
            ),
          )
          .orThrow();

      if (!mounted) return;
      refreshAfterWriteFrom(ref);
      ref.invalidate(leadProvider(widget.lead.leadDomain.id));
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askReason() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('Why are you declining?')),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: context.t('Too far, fully booked, not my trade…'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t('Cancel')),
          ),
          FilledButton(
            // Ops read these. A blank reason tells the coordinator nothing and
            // the same lead comes back next week.
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(context.t('Decline')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final responded =
        lead.assignment.responseStatus != AssignmentResponse.pending;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
      children: [
        const SizedBox(height: Space.md),
        Text(lead.client.displayName, style: context.text.displayLarge),
        const SizedBox(height: Space.xxs),
        Text(
          lead.leadReference,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.xxs,
          runSpacing: Space.xxs,
          children: [
            StatusPill(lead.domain.name, tone: StatusTone.neutral),
            if (lead.won)
              StatusPill(context.t('Won'), tone: StatusTone.verified),
            if (lead.lost)
              StatusPill(context.t('Lost'), tone: StatusTone.wrong),
            if (lead.myQuote != null && !lead.won && !lead.lost)
              StatusPill(
                context.t('Quote v{n} out', {'n': lead.myQuote!.version}),
                tone: StatusTone.waiting,
              ),
          ],
        ),

        /// Accept or decline, before anything else.
        ///
        /// Assignment is manual — ops phone first — so this is confirming what
        /// was already discussed rather than a cold offer. It still has to be
        /// recorded.
        if (!responded) ...[
          const SizedBox(height: Space.lg),
          ActionRequired(
            title: context.t('Can you take this on?'),
            body: context.t(
              'Our team offered you this job. Confirming puts you in the '
              'running; declining tells the coordinator why.',
            ),
            action: Row(
              children: [
                FilledButton(
                  onPressed: _busy ? null : () => _respond(true),
                  child: Text(context.t('Accept')),
                ),
                const SizedBox(width: Space.xs),
                OutlinedButton(
                  onPressed: _busy ? null : () => _respond(false),
                  child: Text(context.t('Decline')),
                ),
              ],
            ),
          ),
        ],

        /// The brief first. It is the real scope.
        if (lead.brief != null && lead.brief!.isNotEmpty) ...[
          SectionHead(
            context.t('The brief'),
            eyebrow: context.t('Captured on the call'),
          ),
          AanganCard(
            padding: const EdgeInsets.all(Space.cardPaddingWide),
            child: Text(lead.brief!, style: context.text.bodyLarge),
          ),
        ],

        SectionHead(
          context.t('In the customer’s words'),
          eyebrow: context.t('As submitted'),
        ),
        AanganCard(
          child: Text(lead.description, style: context.text.bodyMedium),
        ),

        if (lead.siteNotes.isNotEmpty) ...[
          SectionHead(
            context.t('Site notes'),
            eyebrow: context.t('Access and conditions'),
          ),
          AanganCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final note in lead.siteNotes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xxs),
                    child: Text('• $note', style: context.text.bodyMedium),
                  ),
              ],
            ),
          ),
        ],

        if (lead.items.isNotEmpty) ...[
          SectionHead(
            context.t('What they picked'),
            eyebrow: context.t('From the catalogue'),
          ),
          AanganCard(
            padding: const EdgeInsets.symmetric(vertical: Space.xs),
            child: Column(
              children: [
                for (final (index, item) in lead.items.indexed) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.cardPadding,
                      vertical: Space.xs,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.itemName,
                                style: context.text.titleMedium,
                              ),
                              if (item.customerNotes != null)
                                Text(
                                  item.customerNotes!,
                                  style: context.text.bodySmall?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          '×${item.quantity}',
                          style: context.text.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  if (index < lead.items.length - 1) const AanganDivider(),
                ],
              ],
            ),
          ),
        ],

        SectionHead(
          context.t('The job'),
          eyebrow: context.t('Scope and budget'),
        ),
        AanganCard(
          padding: const EdgeInsets.all(Space.cardPaddingWide),
          child: Column(
            children: [
              _Fact(label: context.t('Urgency'), value: lead.urgency),
              const SizedBox(height: Space.xs),
              _Fact(
                label: context.t('Material'),
                value: switch (lead.materialSource) {
                  MaterialSource.vendorSupplied => context.t('You supply'),
                  MaterialSource.customerSupplied => context.t(
                    'Customer supplies',
                  ),
                  MaterialSource.undecided => context.t('Undecided'),
                  MaterialSource.$unknown => context.t('Unknown'),
                },
              ),
              const SizedBox(height: Space.xs),
              _Fact(
                label: context.t('Budget ceiling'),
                value: lead.budgetMax == null
                    ? context.t('Not stated')
                    : Rupees(lead.budgetMax!).formatted,
              ),
              const SizedBox(height: Space.xs),
              _Fact(
                label: context.t('Others quoting'),
                value: '${lead.competingQuotes}',
              ),
            ],
          ),
        ),

        /// The address is not here, and the locality is as far as it goes.
        ///
        /// The full address is released per service, and only once a visit for
        /// *that* service is confirmed. See the visits screen.
        SectionHead(
          context.t('Where'),
          eyebrow: context.t('Locality only, for now'),
        ),
        AanganCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${lead.client.locality}, ${lead.client.city.name}',
                style: context.text.titleLarge,
              ),
              const SizedBox(height: Space.xxs),
              Text(
                lead.client.address == null
                    ? context.t(
                        'The full address is released once a site visit for this '
                        'service is confirmed.',
                      )
                    : lead.client.address!,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: Space.lg),

        if (lead.myQuote != null)
          AanganCard(
            padding: const EdgeInsets.all(Space.cardPaddingWide),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      context.t('Your quote'),
                      style: context.text.headlineSmall,
                    ),
                    const Spacer(),
                    StatusPill(
                      'v${lead.myQuote!.version}',
                      tone: StatusTone.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: Space.xs),
                MoneyText(Rupees(lead.myQuote!.total).formatted),
                const SizedBox(height: Space.xxs),
                Text(
                  context.t('{days} days · {months} months warranty', {
                    'days': lead.myQuote!.timelineDays,
                    'months': lead.myQuote!.warrantyMonths,
                  }),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: Space.md),

        if (!lead.lost)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuoteBuilderScreen(lead: lead),
                      ),
                    ),
              child: Text(
                lead.myQuote == null
                    ? context.t('Send a quote')
                    : context.t('Revise your quote'),
              ),
            ),
          ),

        const SizedBox(height: Space.xs),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => widget.onOpenThread?.call(lead),
            child: Text(
              lead.unreadMessages > 0
                  ? context.t('Messages with Aangan ({n})', {
                      'n': lead.unreadMessages,
                    })
                  : context.t('Messages with Aangan'),
            ),
          ),
        ),
        const SizedBox(height: Space.xs),
        Text(
          // Said plainly, because a vendor will look for the customer's number
          // and should understand why there isn't one.
          context.t(
            'Every message goes through Aangan. We carry questions to the '
            'customer and their answers back to you.',
          ),
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.xxxl),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Text(value, style: context.text.titleMedium)),
      ],
    );
  }
}
