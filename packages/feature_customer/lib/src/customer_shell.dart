/// The customer's five tabs.
///
/// `Home · Explore · Jobs · Messages · Account`, per MOBILE.md §6.1.
///
/// Two of the surfaces that section lists are deliberately absent: the **blog**
/// and the **estimator**. They are MOBILE.md open question 3 — *"the two
/// largest pieces of M11 with the least in-app value; a native blog exists
/// mainly for deep links from search"* — and that is a question for the client
/// rather than a default. Building them speculatively would be the expensive
/// way to find out the answer was no.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_core_upload/aangan_core_upload.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agreements_screen.dart';
import 'async_view.dart';
import 'home_screen.dart';
import 'projects_screen.dart';
import 'providers.dart';
import 'requirement_flow.dart';
import 'requirements_screen.dart';

class CustomerShell extends ConsumerStatefulWidget {
  const CustomerShell({
    super.key,
    required this.queue,
    required this.isSignedIn,
    required this.verify,
    this.onSignOut,
  });

  final UploadQueue queue;
  final bool Function() isSignedIn;
  final VerifyNumber verify;
  final VoidCallback? onSignOut;

  @override
  ConsumerState<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends ConsumerState<CustomerShell> {
  int _tab = 0;

  Future<void> _startRequirement() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RequirementFlow(
          queue: widget.queue,
          isSignedIn: widget.isSignedIn,
          verify: widget.verify,
        ),
      ),
    );
    if (mounted) setState(() => _tab = 2);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onStart: _startRequirement),
      const _ExploreTab(),
      RequirementsScreen(onStartNew: _startRequirement),
      const _MessagesTab(),
      _AccountTab(onSignOut: widget.onSignOut),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'HOME',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'EXPLORE',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'JOBS',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'MESSAGES',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'ACCOUNT',
          ),
        ],
      ),
    );
  }
}

/// The professional directory.
///
/// Ranked by rating **in the trade being browsed**, and the card says which
/// trade the rating is for — an overall average under a trade heading would be
/// the wrong number under the right label.
class _ExploreTab extends ConsumerWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final professionals = ref.watch(professionalsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Space.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              child: Text('Professionals', style: context.text.headlineLarge),
            ),
            const SizedBox(height: Space.sm),
            Expanded(
              child: AsyncView(
                value: professionals,
                onRetry: () => ref.invalidate(professionalsProvider),
                data: (page) => page.items.isEmpty
                    ? const EmptyState(
                        title: 'Nobody to show yet',
                        body: 'Professionals appear here once they are verified.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.gutter,
                          vertical: Space.xs,
                        ),
                        itemCount: page.items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: Space.sm),
                        itemBuilder: (context, i) =>
                            ProfessionalCard(professional: page.items[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfessionalCard extends StatelessWidget {
  const ProfessionalCard({super.key, required this.professional});

  final ProfessionalSummary professional;

  @override
  Widget build(BuildContext context) {
    final domainRating = professional.domainRating;
    final rating = domainRating?.avgRating ?? professional.avgRating;
    final count = domainRating?.ratingCount ?? professional.ratingCount;

    return AanganCard(
      padding: const EdgeInsets.all(Space.cardPaddingWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  professional.companyName,
                  style: context.text.headlineSmall,
                ),
              ),
              if (professional.isVerified)
                const StatusPill('Verified', tone: StatusTone.verified),
            ],
          ),
          const SizedBox(height: Space.xxs),
          Text(
            '${professional.city.name} · ${professional.experienceYears} years',
            style: context.text.bodySmall
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: Space.xs),
          Text(
            // Says which trade the rating is for, always.
            count == 0
                ? 'No reviews yet'
                : '${rating.toStringAsFixed(1)} ★ · $count reviews'
                    '${domainRating == null ? " across all trades" : ""}',
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: Space.xs),
          Wrap(
            spacing: Space.xxs,
            runSpacing: Space.xxs,
            children: [
              for (final domain in professional.domains)
                StatusPill(domain.name, tone: StatusTone.neutral),
            ],
          ),
        ],
      ),
    );
  }
}

/// One thread per service, and the platform is on the other side of every one.
class _MessagesTab extends ConsumerWidget {
  const _MessagesTab();

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Messages', style: context.text.headlineLarge),
                  const SizedBox(height: Space.xxs),
                  Text(
                    // Stated plainly, as MOBILE.md §6.1 asks: one thread per
                    // service, with Aangan, and we carry messages both ways.
                    'You talk to us, and we talk to the professionals. One '
                    'conversation per job.',
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
            Expanded(
              child: AsyncView(
                value: requirements,
                onRetry: () => ref.invalidate(requirementsProvider),
                data: (list) {
                  final services = [
                    for (final lead in list)
                      for (final service in lead.domains) (lead, service),
                  ];

                  if (services.isEmpty) {
                    return const EmptyState(
                      title: 'No conversations yet',
                      body: 'A thread opens for each job once you submit it.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.gutter,
                      vertical: Space.xs,
                    ),
                    itemCount: services.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: Space.xs),
                    itemBuilder: (context, i) {
                      final (lead, service) = services[i];
                      return AanganCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ServiceThreadScreen(
                              leadDomainId: service.leadDomain.id,
                              title: service.domain.name,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.domain.name,
                                    style: context.text.titleLarge,
                                  ),
                                  Text(
                                    lead.lead.reference,
                                    style: context.text.bodySmall?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (service.unreadMessages > 0)
                              StatusPill(
                                '${service.unreadMessages}',
                                tone: StatusTone.yours,
                              ),
                            Icon(
                              Icons.chevron_right,
                              color: context.colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      );
                    },
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

/// The customer half of the relay.
class ServiceThreadScreen extends ConsumerStatefulWidget {
  const ServiceThreadScreen({
    super.key,
    required this.leadDomainId,
    required this.title,
  });

  final String leadDomainId;
  final String title;

  @override
  ConsumerState<ServiceThreadScreen> createState() => _ServiceThreadScreenState();
}

class _ServiceThreadScreenState extends ConsumerState<ServiceThreadScreen> {
  final _body = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _body.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    try {
      await ref
          .read(apiProvider)
          .customer
          .sendServiceMessage(
            id: widget.leadDomainId,
            body: SendServiceMessageBody(body: text),
          )
          .orThrow();
      _body.clear();
      ref.invalidate(serviceThreadProvider(widget.leadDomainId));
      refreshAfterWrite(ref);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(serviceThreadProvider(widget.leadDomainId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aangan'),
            Text(
              'about your ${widget.title.toLowerCase()}',
              style: context.text.bodySmall
                  ?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: context.colors.surfaceContainer,
              padding: const EdgeInsets.symmetric(
                horizontal: Space.gutter,
                vertical: Space.xs,
              ),
              child: Text(
                'Your coordinator reads this and passes anything relevant to '
                'the professionals quoting for you.',
                style: context.text.bodySmall
                    ?.copyWith(color: context.colors.onSurfaceVariant),
              ),
            ),
            Expanded(
              child: AsyncView(
                value: thread,
                onRetry: () =>
                    ref.invalidate(serviceThreadProvider(widget.leadDomainId)),
                data: (messages) => messages.isEmpty
                    ? const EmptyState(
                        title: 'Nothing yet',
                        body: 'Ask us anything about your job.',
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.gutter,
                          vertical: Space.sm,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, i) {
                          final message = messages[messages.length - 1 - i];
                          final mine =
                              message.senderRole == MessageSenderRole.client;
                          return Align(
                            alignment:
                                mine ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: Space.xs),
                              padding: const EdgeInsets.all(Space.sm),
                              constraints: const BoxConstraints(maxWidth: 300),
                              decoration: BoxDecoration(
                                color: mine
                                    ? context.colors.surfaceContainerHighest
                                    : AanganColors.chalk,
                                borderRadius: Radii.panelRadius,
                                border:
                                    Border.all(color: context.palette.hairline),
                              ),
                              child: Column(
                                crossAxisAlignment: mine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mine ? 'You' : 'Aangan',
                                    style: context.text.labelMedium?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: Space.xxs),
                                  Text(message.body,
                                      style: context.text.bodyMedium),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _body,
                      enabled: !_sending,
                      minLines: 1,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(hintText: 'Message Aangan'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: Space.xs),
                  FilledButton(
                    onPressed:
                        _body.text.trim().isEmpty || _sending ? null : _send,
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

class _AccountTab extends ConsumerWidget {
  const _AccountTab({this.onSignOut});

  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            const SizedBox(height: Space.md),
            Text('Account', style: context.text.headlineLarge),
            const SizedBox(height: Space.md),
            _Link(
              title: 'Agreements',
              subtitle: 'Contracts to sign, and signed',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AgreementsScreen()),
              ),
            ),
            const SizedBox(height: Space.xs),
            _Link(
              title: 'Progress',
              subtitle: 'Work under way',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProjectsScreen()),
              ),
            ),
            if (onSignOut != null) ...[
              const SizedBox(height: Space.xl),
              OutlinedButton(onPressed: onSignOut, child: const Text('Sign out')),
            ],
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.title, required this.subtitle, required this.onTap});

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
                  style: context.text.bodySmall
                      ?.copyWith(color: context.colors.onSurfaceVariant),
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
