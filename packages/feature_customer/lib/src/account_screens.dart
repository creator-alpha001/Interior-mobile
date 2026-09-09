/// Notifications, referrals and support.
///
/// The web's `/account/notifications`, `/account/referrals` and
/// `/account/support`. None existed on mobile: `listNotifications`,
/// `markNotificationsRead`, `referrals`, `listTickets`, `createTicket` and
/// `replyToTicket` were all unreachable, and `notifications.dart` in the app
/// routed a notification *tap* without there being anywhere to see the list.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_design/interiobee_design.dart';
// Flutter has a `Notification` of its own — the scroll/size notification
// base class — and the generated client has the platform's. Left ambiguous,
// Dart resolves neither and quietly types every field access as `dynamic`,
// so `notification.title` compiles and fails at the call site instead.
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'async_view.dart';
import 'customer_shell.dart';
import 'providers.dart';
import 'quote_comparison.dart';

/// Every read these screens need already exists in `providers.dart`.
///
/// `notificationsProvider`, `ticketsProvider` and `referralsProvider` were all
/// written when these screens were planned, and then sat there with nothing to
/// read them — which is the same signal as an unreachable client method, one
/// level up.

/* ------------------------------------------------------------------ *
 * Notifications
 * ------------------------------------------------------------------ */

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    /// Marked read on open, not on tap.
    ///
    /// The badge counts what somebody has not *seen*, and they have now seen
    /// the list. Marking per-row would leave a badge showing three while the
    /// screen shows three rows the person has plainly read.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref
            .read(customerApiProvider)
            .customer
            .markNotificationsRead()
            .orThrow();
        if (mounted) ref.invalidate(notificationsProvider);
      } on ApiException {
        // Failing to clear a badge is not worth an error state over the list
        // it is a badge for. It will clear on the next visit.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Notifications'))),
      body: SafeArea(
        child: AsyncView(
          value: notifications,
          onRetry: () => ref.invalidate(notificationsProvider),
          data: (list) => list.isEmpty
              ? EmptyState(
                  title: context.t('Nothing to tell you'),
                  body: context.t(
                    'We write here when something needs you — quotes arriving, '
                    'an agreement to sign, a visit confirmed.',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(notificationsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(Space.gutter),
                    itemCount: list.length,
                    separatorBuilder: (context, i) =>
                        const SizedBox(height: Space.xs),
                    itemBuilder: (context, i) =>
                        _NotificationRow(notification: list[i]),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Where a notification's own record lives, given what is loaded.
///
/// `core_push`'s `deepLinkFor` answers the same question as a URL — for a
/// router that does not have these routes yet, because both shells are
/// `IndexedStack`s with their own `Navigator` rather than nested go_router
/// routes. This answers it as a *widget*, which is the form today's
/// architecture can actually use. When the shells move onto nested routes the
/// two collapse into one table, and that is the right time to do it — not by
/// half-parsing a location string here.
///
/// Returns null when there is no screen addressed by that id. A row that does
/// nothing is better than one that opens a list and leaves somebody to find
/// the thing again, and the row does not look tappable when this is null.
Widget? _recordFor(Notification notification, List<LeadView> requirements) {
  final id = notification.entityId;
  if (id == null) return null;

  /// The service the notification is about, found across every requirement.
  ///
  /// `orElse` rather than `firstWhere`'s throw: a notification can outlive the
  /// requirement it points at, and an exception inside a list builder would
  /// take down a screen whose whole job is to be readable.
  (LeadView, LeadDomainView)? service;
  for (final requirement in requirements) {
    for (final domain in requirement.domains) {
      if (domain.leadDomain.id == id) service = (requirement, domain);
    }
  }

  return switch (notification.entityType) {
    NotificationEntityType.message when service != null => ServiceThreadScreen(
      leadDomainId: service.$2.leadDomain.id,
      title: service.$2.domain.name,
    ),

    // Quotes are compared per service, and the screen needs the requirement
    // it belongs to as well as the service itself.
    NotificationEntityType.quote when service != null =>
      service.$2.quotes.isEmpty
          ? null
          : QuoteComparisonScreen(
              service: service.$2,
              requirementId: service.$1.lead.id,
            ),
    NotificationEntityType.leadDomain when service != null =>
      service.$2.quotes.isEmpty
          ? null
          : QuoteComparisonScreen(
              service: service.$2,
              requirementId: service.$1.lead.id,
            ),

    _ => null,
  };
}

class _NotificationRow extends ConsumerWidget {
  const _NotificationRow({required this.notification});

  final Notification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Whatever is already loaded, and nothing fetched for this.
    ///
    /// The Jobs tab has almost always run by the time somebody opens their
    /// notifications. If it has not, the row is simply not tappable — which is
    /// the honest state, and better than a spinner on a list row.
    final requirements = ref
        .watch(requirementsProvider)
        .maybeWhen(data: (list) => list, orElse: () => const <LeadView>[]);
    final record = _recordFor(notification, requirements);

    return InterioBeeCard(
      // Unread sits on the peach panel. It is the one colour that means "you",
      // and an unread notification is by definition waiting on the reader.
      nested: notification.isRead,
      onTap: record == null
          ? null
          : () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => record)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!notification.isRead) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: Space.xs),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Written by the server, which knows why it fired.
                Text(notification.title, style: context.text.titleMedium),
                const SizedBox(height: Space.xxs),
                Text(
                  notification.body,
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

/* ------------------------------------------------------------------ *
 * Referrals
 * ------------------------------------------------------------------ */

class ReferralsScreen extends ConsumerWidget {
  const ReferralsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referrals = ref.watch(referralsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Invite a friend'))),
      body: SafeArea(
        child: AsyncView(
          value: referrals,
          onRetry: () => ref.invalidate(referralsProvider),
          data: (summary) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            children: [
              const SizedBox(height: Space.md),
              Text(
                context.t('Invite a friend'),
                style: context.text.displayLarge,
              ),
              const SizedBox(height: Space.sm),
              Text(
                context.t(
                  'They get somebody who answers, and you get {amount} once '
                  'their first job is signed.',
                  {'amount': Rupees(summary.rewardPerReferral).formatted},
                ),
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: Space.lg),
              InterioBeeCard(
                padding: const EdgeInsets.all(Space.cardPaddingWide),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('Your code'),
                      style: context.text.labelMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Space.xxs),
                    Text(
                      // Monospace-ish weight and letter spacing: this is a
                      // string somebody reads aloud over a phone call.
                      summary.code,
                      style: InterioBeeTextStyles.financialNum.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: Space.sm),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Share.share(
                          context.t(
                            'I used InterioBee for interior work — they find you '
                            'three verified professionals and stay between '
                            'you. Use my code {code}: {url}',
                            {'code': summary.code, 'url': summary.shareUrl},
                          ),
                        ),
                        icon: const Icon(Icons.share_outlined),
                        label: Text(context.t('Share')),
                      ),
                    ),
                  ],
                ),
              ),

              SectionHead(
                context.t('How it is going'),
                eyebrow: context.t('So far'),
              ),
              Row(
                children: [
                  _Figure(
                    label: context.t('Invited'),
                    value: '${summary.invited}',
                  ),
                  _Figure(
                    label: context.t('Earned'),
                    value: Rupees(summary.earned).short,
                  ),
                  _Figure(
                    label: context.t('Pending'),
                    value: Rupees(summary.pending).short,
                  ),
                ],
              ),

              if (summary.referrals.isNotEmpty) ...[
                SectionHead(
                  context.t('Who you invited'),
                  eyebrow: context.t('And where it got to'),
                ),
                for (final entry in summary.referrals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xs),
                    child: InterioBeeCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.name,
                              style: context.text.titleMedium,
                            ),
                          ),
                          StatusPill(
                            entry.referral.rewardStatus.name,
                            tone:
                                entry.referral.rewardStatus ==
                                    ReferralRewardStatus.paid
                                ? StatusTone.verified
                                : StatusTone.waiting,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: Space.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: context.text.headlineSmall),
          Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------ *
 * Support
 * ------------------------------------------------------------------ */

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Help'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NewTicketScreen())),
        icon: const Icon(Icons.add),
        label: Text(context.t('Ask us something')),
      ),
      body: SafeArea(
        child: AsyncView(
          value: tickets,
          onRetry: () => ref.invalidate(ticketsProvider),
          data: (list) => list.isEmpty
              ? EmptyState(
                  title: context.t('Nothing open'),
                  body: context.t(
                    'Anything at all — a price you do not understand, a '
                    'professional who has gone quiet, a date that will not '
                    'work. A person reads these.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(Space.gutter),
                  itemCount: list.length,
                  separatorBuilder: (context, i) =>
                      const SizedBox(height: Space.xs),
                  itemBuilder: (context, i) => _TicketRow(ticket: list[i]),
                ),
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final open = ticket.status != SupportTicketStatus.closed;

    return InterioBeeCard(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => TicketScreen(ticket: ticket))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(ticket.subject, style: context.text.titleLarge),
              ),
              StatusPill(
                ticket.status.name,
                tone: open ? StatusTone.waiting : StatusTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: Space.xxs),
          Text(
            ticket.reference,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key, required this.ticket});

  final SupportTicket ticket;

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  final _reply = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _reply.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    try {
      await ref
          .read(customerApiProvider)
          .customer
          .replyToTicket(
            id: widget.ticket.id,
            body: SendServiceMessageBody(body: text),
          )
          .orThrow();
      _reply.clear();
      ref.invalidate(ticketsProvider);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;

    return Scaffold(
      appBar: AppBar(title: Text(ticket.reference)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
                children: [
                  const SizedBox(height: Space.md),
                  Text(ticket.subject, style: context.text.headlineLarge),
                  const SizedBox(height: Space.sm),
                  Text(ticket.body, style: context.text.bodyLarge),
                  const SizedBox(height: Space.md),
                  const InterioBeeDivider(inset: 0),
                  for (final reply in ticket.replies)
                    Padding(
                      padding: const EdgeInsets.only(top: Space.sm),
                      child: InterioBeeCard(
                        // InterioBee's replies sit on the peach panel; the customer's own
                        // sit plain, so a thread reads as a conversation.
                        nested:
                            reply.authorRole == TicketReplyAuthorRole.platform,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reply.authorName,
                              style: context.text.labelMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: Space.xxs),
                            Text(reply.body, style: context.text.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: Space.xxxl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _reply,
                      enabled: !_sending,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: context.t('Add to this'),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: Space.xs),
                  FilledButton(
                    onPressed: _reply.text.trim().isEmpty || _sending
                        ? null
                        : _send,
                    child: const Icon(Icons.send, size: TapTarget.glyph),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewTicketScreen extends ConsumerStatefulWidget {
  const NewTicketScreen({super.key});

  @override
  ConsumerState<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends ConsumerState<NewTicketScreen> {
  final _subject = TextEditingController();
  final _body = TextEditingController();
  CreateTicketBodyCategory _category = CreateTicketBodyCategory.query;
  bool _sending = false;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  /// The categories, as literals so the l10n scan can see them.
  String _label(BuildContext context, CreateTicketBodyCategory category) =>
      switch (category) {
        // The API's own five, worded as a customer would say them rather than
        // as ops files them.
        CreateTicketBodyCategory.query => context.t('A question'),
        CreateTicketBodyCategory.complaint => context.t('Something is wrong'),
        CreateTicketBodyCategory.escalation => context.t('This is urgent'),
        CreateTicketBodyCategory.refund => context.t('Money'),
        CreateTicketBodyCategory.technical => context.t('The app itself'),
        // A category added after this build shipped. Falls back to
        // the general one rather than showing a blank chip.
        CreateTicketBodyCategory.$unknown => context.t('A question'),
      };

  Future<void> _send() async {
    setState(() => _sending = true);
    try {
      await ref
          .read(customerApiProvider)
          .customer
          .createTicket(
            body: CreateTicketBody(
              category: _category,
              subject: _subject.text.trim(),
              body: _body.text.trim(),
            ),
          )
          .orThrow();
      ref.invalidate(ticketsProvider);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready =
        _subject.text.trim().length > 3 && _body.text.trim().length > 10;

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Ask us something'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            const SizedBox(height: Space.md),
            Text(
              context.t(
                'A person reads this, not a robot. The more specific you are, '
                'the faster they can do something about it.',
              ),
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            SectionHead(
              context.t('What is it about?'),
              eyebrow: context.t('So it reaches the right person'),
            ),
            Wrap(
              spacing: Space.xxs,
              runSpacing: Space.xxs,
              children: [
                for (final category in CreateTicketBodyCategory.values)
                  ChoiceChip(
                    label: Text(_label(context, category)),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
              ],
            ),

            const SizedBox(height: Space.md),
            TextField(
              controller: _subject,
              enabled: !_sending,
              decoration: InputDecoration(labelText: context.t('In one line')),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: Space.sm),
            TextField(
              controller: _body,
              enabled: !_sending,
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: context.t('What happened'),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: Space.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: ready && !_sending ? _send : null,
                child: Text(context.t('Send')),
              ),
            ),
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }
}
