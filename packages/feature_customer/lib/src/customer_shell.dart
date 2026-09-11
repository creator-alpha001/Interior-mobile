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

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_core_upload/interiobee_core_upload.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'about_screens.dart';
import 'account_screens.dart';
import 'agreements_screen.dart';
import 'become_professional_screen.dart';
import 'blog_screen.dart';
import 'catalogue.dart';
import 'packages_screen.dart';
import 'professional_screen.dart';
import 'search_screen.dart';
import 'estimator_screen.dart';
import 'filter_choices.dart';
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
    required this.authChanges,
    required this.isSignedIn,
    required this.verify,
    this.onSignOut,
    this.setupNeeds,
    this.onFinishSetup,
  });

  final UploadQueue queue;

  /// What signup let the signed-in customer skip, asked afresh on each build
  /// so the home strip goes away the moment it is answered.
  final SetupNeeds? Function()? setupNeeds;

  /// Opens the screen that asks for a city and a number. The app owns it,
  /// because adding a number runs through the auth controller.
  final Future<void> Function(BuildContext context)? onFinishSetup;

  /// Fires when somebody signs in or out.
  ///
  /// A `Listenable` rather than the controller itself, so this package still
  /// depends on nothing but the API client and the design system. What it
  /// needs is "tell me when this changed"; who changed it is the app's
  /// business.
  final Listenable authChanges;

  final bool Function() isSignedIn;

  /// Raises the sign-in screen and reports whether a session now exists.
  ///
  /// Named for the requirement flow, which has always used it to verify at the
  /// last step. Every other surface that needs an account now uses the same
  /// one, so there is one sign-in screen and one answer.
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

  /// Raises sign-in, and rebuilds this shell if it worked.
  ///
  /// `authChanges` already rebuilds it, but the await is what lets a caller
  /// carry on with whatever they were doing.
  Future<bool> _signIn() async {
    final signedIn = await widget.verify(context);
    if (mounted) setState(() {});
    return signedIn;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authChanges,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final signedIn = widget.isSignedIn();

    /// Two tabs are a person's own record and nothing else, so signed out
    /// there is nothing to render but the reason. Home and Explore are public
    /// — the API serves both to an anonymous caller — and Account carries the
    /// sign-in button along with the pages anybody can read.
    final screens = [
      HomeScreen(
        onStart: _startRequirement,
        onOpenJobs: () => setState(() => _tab = 2),
        onSignIn: signedIn ? null : _signIn,
        setup: signedIn ? widget.setupNeeds?.call() : null,
        onFinishSetup: widget.onFinishSetup == null
            ? null
            : () => widget.onFinishSetup!(context),
      ),
      _ExploreTab(onStart: _startRequirement),
      if (signedIn)
        RequirementsScreen(onStartNew: _startRequirement)
      else
        _SignInWall(
          title: context.t('Your jobs live here'),
          body: context.t(
            'Sign in to see the quotes on your jobs, the visits we have '
            'arranged, and where each one has got to.',
          ),
          onSignIn: _signIn,
          onStart: _startRequirement,
        ),
      if (signedIn)
        const _MessagesTab()
      else
        _SignInWall(
          title: context.t('One conversation per job'),
          body: context.t(
            'You talk to us and we talk to the professionals. Sign in to see '
            'your threads.',
          ),
          onSignIn: _signIn,
          onStart: _startRequirement,
        ),
      _AccountTab(
        onSignOut: widget.onSignOut,
        onSignIn: signedIn ? null : _signIn,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),

        /// Written as words in the table, uppercased here for display.
        ///
        /// `NavigationDestination.label` is a String rather than a widget, so
        /// there is nowhere for the theme to do this — and unlike the status
        /// pill there is no separate semantics label to preserve the word in.
        ///
        /// Calling `toUpperCase()` unconditionally is right in both languages
        /// rather than only in one: Devanagari has no case, so Unicode maps
        /// every one of its letters to itself. `'होम'.toUpperCase()` is `'होम'`.
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: context.t('Home').toUpperCase(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view),
            label: context.t('Explore').toUpperCase(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment),
            label: context.t('Jobs').toUpperCase(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.forum_outlined),
            selectedIcon: const Icon(Icons.forum),
            label: context.t('Messages').toUpperCase(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: context.t('Account').toUpperCase(),
          ),
        ],
      ),
    );
  }
}

/// What a tab shows when it is entirely somebody's own record.
///
/// Not an error and not an empty state: there is nothing wrong and nothing
/// missing, the app simply does not know who is asking yet. It says what is
/// behind the door before asking anybody to open it, and offers the other way
/// in — somebody with no account and no jobs wants the form, not a password.
class _SignInWall extends StatelessWidget {
  const _SignInWall({
    required this.title,
    required this.body,
    required this.onSignIn,
    required this.onStart,
  });

  final String title;
  final String body;
  final Future<bool> Function() onSignIn;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.displayLarge),
                const SizedBox(height: Space.sm),
                Text(
                  body,
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Space.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onSignIn,
                    child: Text(context.t('Sign in')),
                  ),
                ),
                const SizedBox(height: Space.xs),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onStart,
                    child: Text(context.t('Tell us what you need')),
                  ),
                ),
                const SizedBox(height: Space.sm),

                /// The thing that makes the second button the right one for
                /// most people who land here, and it is true: the form runs to
                /// the end without an account and verifies at the last step.
                Text(
                  context.t(
                    'No account needed to start — we ask for your number at '
                    'the end, to send the quotes to.',
                  ),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
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
  const _ExploreTab({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final professionals = ref.watch(professionalsProvider);
    final filters = ref.watch(professionalFiltersProvider);

    /// **One scroll view, not a fixed header with a scrolling sliver.**
    ///
    /// This was a `Column` of fixed children ending in `Expanded(ListView)`,
    /// which meant the search field, five shortcuts, heading and two filter
    /// rows held their full height on every screen size and the directory —
    /// the actual content — got whatever was left. On a 1080×2400 emulator
    /// that was about a card and a half, with the one above it clipped mid-air
    /// against the filters. On anything shorter it would have been worse.
    ///
    /// Everything scrolls together now. The shortcuts scroll away and the
    /// professionals get the whole screen, which is the right priority: the
    /// menu is read once, the directory is browsed.
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: Space.md),

            /// Search sits above the browse grid rather than inside it.
            ///
            /// Somebody who knows what they want should not have to pick a
            /// category first — that is the whole argument for search, and
            /// burying it behind a shortcut tile would undo it.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              child: _SearchBar(onStart: onStart),
            ),
            const SizedBox(height: Space.md),

            /// Everything browsable that is not the directory below.
            ///
            /// In a grid here rather than in tabs of their own: five tabs is
            /// the ceiling MOBILE.md §6.1 sets, and a sixth would cost one that
            /// carries a job. Explore is where the web's whole `/catalogue`,
            /// `/our-work`, `/blog` and `/estimate` branch lands.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Shortcut(
                          icon: Icons.grid_view_outlined,
                          title: context.t('Catalogue'),
                          subtitle: context.t('What we make'),
                          onTap: () => openCatalogue(context, ref),
                        ),
                      ),
                      const SizedBox(width: Space.xs),
                      Expanded(
                        child: _Shortcut(
                          icon: Icons.photo_library_outlined,
                          title: context.t('Our work'),
                          subtitle: context.t('Jobs already done'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OurWorkScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _Shortcut(
                          icon: Icons.calculate_outlined,
                          title: context.t('Rough cost'),
                          subtitle: context.t('No account needed'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EstimatorScreen(onStart: onStart),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Space.xs),
                      Expanded(
                        child: _Shortcut(
                          icon: Icons.menu_book_outlined,
                          title: context.t('Guides'),
                          subtitle: context.t('What things cost'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BlogScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _Shortcut(
                          icon: Icons.inventory_2_outlined,
                          title: context.t('Packages'),
                          subtitle: context.t('Fixed scope, fixed price'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PackagesScreen(onStart: onStart),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Space.xs),
                      // A spacer, so a lone tile does not stretch across the
                      // row and read as a different kind of control.
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: Space.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.t('Professionals'),
                      style: context.text.headlineLarge,
                    ),
                  ),

                  /// City, verification, rating and experience, behind one
                  /// button that counts them — the web's filter sidebar folded
                  /// into a sheet. Four more rows of chips stacked here would
                  /// push the directory off the first screen again.
                  OutlinedButton.icon(
                    onPressed: () => _showProfessionalFilters(context),
                    icon: Badge(
                      isLabelVisible: filters.activeCount > 0,
                      label: Text('${filters.activeCount}'),
                      child: const Icon(Icons.tune, size: TapTarget.glyph),
                    ),
                    label: Text(context.t('Filter')),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
              child: Text(
                context.t('Rated per trade, badged when verified'),
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: Space.xs),

            /// Trade, then city — the two the web carries in its query string.
            ///
            /// The trade filter is not cosmetic. It is what makes the API
            /// return `domainRating`, so a card under "Carpentry" shows the
            /// carpentry rating rather than a blended average that flatters a
            /// painter who has never built a wardrobe.
            FilterRow(
              label: context.t('Trade'),
              allLabel: context.t('All'),
              selected: filters.domainSlug,
              options: ref
                  .watch(domainsProvider)
                  .maybeWhen(
                    data: (list) => [for (final d in list) (d.slug, d.name)],
                    orElse: () => const <(String, String)>[],
                  ),
              onSelect: (slug) => ref
                  .read(professionalFiltersProvider.notifier)
                  .update((f) => f.copyWith(domainSlug: slug)),
            ),
            _ProfessionalSorts(
              selected: filters.sort,
              onSelect: (sort) => ref
                  .read(professionalFiltersProvider.notifier)
                  .update((f) => f.copyWith(sort: sort)),
            ),
            professionals.maybeWhen(
              data: (page) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.gutter,
                  Space.xs,
                  Space.gutter,
                  0,
                ),
                child: Text(
                  context.l10n.plural(
                    page.items.length,
                    '{n} professional',
                    '{n} professionals',
                  ),
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),

            const SizedBox(height: Space.sm),

            /// Built in one pass rather than lazily, because the request asks
            /// for 48 and the outer list is what scrolls now. A nested
            /// scrollable here is what produced the sliver this screen used to
            /// be.
            AsyncView(
              value: professionals,
              onRetry: () => ref.invalidate(professionalsProvider),
              data: (page) => page.items.isEmpty
                  ? EmptyState(
                      title: context.t('Nobody to show yet'),
                      // Two reasons for an empty list, and they call for
                      // different things from the reader. Saying "once they
                      // are verified" under a filter somebody just set would
                      // blame the pool for their own narrowing.
                      body:
                          filters.domainSlug != null || filters.activeCount > 0
                          ? context.t(
                              'Nobody matches these filters yet. We source '
                              'and verify professionals for new areas '
                              'continuously — tell us what you need anyway.',
                            )
                          : context.t(
                              'Professionals appear here once our team '
                              'approves them.',
                            ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.gutter,
                        vertical: Space.xs,
                      ),
                      child: Column(
                        children: [
                          for (final professional in page.items) ...[
                            ProfessionalCard(professional: professional),
                            const SizedBox(height: Space.sm),
                          ],
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }
}

/// The directory's three sorts, in the web's order.
class _ProfessionalSorts extends StatelessWidget {
  const _ProfessionalSorts({required this.selected, required this.onSelect});

  final Sort2 selected;
  final ValueChanged<Sort2> onSelect;

  static const _order = <Sort2>[Sort2.rating, Sort2.experience, Sort2.projects];

  /// Literals at the call site, for the same reason as the catalogue's sorts:
  /// `l10n_test.dart` can only see a string written inside `context.t(`.
  static String _label(BuildContext context, Sort2 sort) => switch (sort) {
    Sort2.rating => context.t('Top rated'),
    Sort2.experience => context.t('Most experienced'),
    Sort2.projects => context.t('Most projects'),
    Sort2.$unknown => context.t('Top rated'),
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TapTarget.minimum,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
        children: [
          for (final sort in _order) ...[
            ChoiceChip(
              label: Text(_label(context, sort)),
              selected: selected == sort,
              onSelected: (_) => onSelect(sort),
            ),
            const SizedBox(width: Space.xs),
          ],
        ],
      ),
    );
  }
}

Future<void> _showProfessionalFilters(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    builder: (_) => const _ProfessionalFilterSheet(),
  );
}

/// The web's filter sidebar for `/professionals`, section for section.
class _ProfessionalFilterSheet extends ConsumerWidget {
  const _ProfessionalFilterSheet();

  static const _ratings = <double>[4.5, 4, 3.5];
  static const _experience = <int>[10, 5, 2];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(professionalFiltersProvider);
    final notifier = ref.read(professionalFiltersProvider.notifier);
    final cities = ref
        .watch(citiesProvider)
        .maybeWhen(data: (list) => list, orElse: () => const <City>[]);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
        children: [
          const SizedBox(height: Space.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.t('Filter'),
                  style: context.text.headlineSmall,
                ),
              ),
              if (filters.activeCount > 0)
                TextButton(
                  onPressed: () {
                    notifier.state = ProfessionalFilters(
                      domainSlug: filters.domainSlug,
                      sort: filters.sort,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(context.t('Clear all')),
                ),
            ],
          ),
          SectionHead(context.t('City')),
          FilterChoices<String>(
            options: [
              (null, context.t('All cities')),
              for (final city in cities) (city.id, city.name),
            ],
            selected: filters.cityId,
            onSelect: (id) => notifier.update((f) => f.copyWith(cityId: id)),
          ),
          SectionHead(context.t('Verification')),
          FilterChoices<bool>(
            options: [
              (false, context.t('All approved professionals')),
              (true, context.t('Verified only')),
            ],
            selected: filters.verifiedOnly,
            onSelect: (on) =>
                notifier.update((f) => f.copyWith(verifiedOnly: on ?? false)),
          ),
          SectionHead(context.t('Rating')),
          FilterChoices<double>(
            options: [
              (null, context.t('Any rating')),
              for (final r in _ratings)
                (
                  r,
                  context.t('{rating} ★ and above', {'rating': ratingFloor(r)}),
                ),
            ],
            selected: filters.minRating,
            onSelect: (r) => notifier.update((f) => f.copyWith(minRating: r)),
          ),
          SectionHead(context.t('Experience')),
          FilterChoices<int>(
            options: [
              (null, context.t('Any experience')),
              for (final n in _experience)
                (n, context.t('{n}+ years', {'n': n})),
            ],
            selected: filters.minExperience,
            onSelect: (n) =>
                notifier.update((f) => f.copyWith(minExperience: n)),
          ),
          const SizedBox(height: Space.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.t('Show results')),
            ),
          ),
          const SizedBox(height: Space.xxxl),
        ],
      ),
    );
  }
}

/// One professional, drawn as the web's card is.
///
/// A photograph of their trade across the top, their mark overlapping its
/// lower edge, and the name *below* it on the card — never over the
/// photograph, where a busy room made it unreadable.
class ProfessionalCard extends StatelessWidget {
  const ProfessionalCard({super.key, required this.professional});

  final ProfessionalSummary professional;

  static const _avatar = 56.0;

  @override
  Widget build(BuildContext context) {
    final domainRating = professional.domainRating;
    final rating = domainRating?.avgRating ?? professional.avgRating;
    final count = domainRating?.ratingCount ?? professional.ratingCount;

    /// Keyed to the professional, so the same person always gets the same
    /// photograph, from the pool for their first trade.
    final trade = professional.domains.firstOrNull?.slug ?? 'default';

    return InterioBeeCard(
      padding: EdgeInsets.zero,
      // The directory used to be a dead end: a list of names with nothing
      // behind them, while `getProfessional` was reachable from nowhere.
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProfessionalScreen(id: professional.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Radii.panel),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: InterioBeeMedia(
                    src: 'ph:$trade:${professional.id}',
                    alt: professional.companyName,
                    rounded: false,
                  ),
                ),
              ),
              Positioned(
                left: Space.cardPaddingWide,
                bottom: -_avatar / 2,
                child: _Avatar(professional: professional, size: _avatar),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.cardPaddingWide,
              _avatar / 2 + Space.xs,
              Space.cardPaddingWide,
              Space.cardPaddingWide,
            ),
            child: _ProfessionalDetails(
              professional: professional,
              rating: rating,
              count: count,
            ),
          ),
        ],
      ),
    );
  }
}

/// Their photograph when they have one, the first letter of the firm when not.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.professional, required this.size});

  final ProfessionalSummary professional;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = professional.avatarUrl;
    final name = professional.companyName.trim();

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.primaryContainer,
        border: Border.all(color: InterioBeeColors.chalk, width: 3),
      ),
      child: url != null && url.isNotEmpty
          ? SizedBox.expand(
              child: InterioBeeMedia(
                src: url,
                alt: professional.companyName,
                rounded: false,
              ),
            )
          : ExcludeSemantics(
              child: Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: context.text.headlineSmall?.copyWith(
                  color: context.colors.onPrimaryContainer,
                ),
              ),
            ),
    );
  }
}

class _ProfessionalDetails extends StatelessWidget {
  const _ProfessionalDetails({
    required this.professional,
    required this.rating,
    required this.count,
  });

  final ProfessionalSummary professional;
  final num rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    final domainRating = professional.domainRating;

    return Column(
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
              StatusPill(context.t('Verified'), tone: StatusTone.verified),
          ],
        ),
        const SizedBox(height: Space.xxs),
        Text(
          // A vendor with no city on record still belongs on the card; the
          // line just says less about them. See ProfessionalSummary.city.
          professional.city == null
              ? context.t('{n} years', {'n': professional.experienceYears})
              : context.t('{city} · {n} years', {
                  'city': professional.city!.name,
                  'n': professional.experienceYears,
                }),
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Space.xs),
        Text(
          // Says which trade the rating is for, always.
          count == 0
              ? context.t('No reviews yet')
              : domainRating == null
              ? context.t('{rating} ★ · {n} reviews across all trades', {
                  'rating': rating.toStringAsFixed(1),
                  'n': count,
                })
              : context.t('{rating} ★ · {n} reviews', {
                  'rating': rating.toStringAsFixed(1),
                  'n': count,
                }),
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
                  Text(
                    context.t('Messages'),
                    style: context.text.headlineLarge,
                  ),
                  const SizedBox(height: Space.xxs),
                  Text(
                    // Stated plainly, as MOBILE.md §6.1 asks: one thread per
                    // service, with Decora Shine, and we carry messages both ways.
                    context.t(
                      'You talk to us, and we talk to the professionals. One '
                      'conversation per job.',
                    ),
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
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
                    return EmptyState(
                      title: context.t('No conversations yet'),
                      body: context.t(
                        context.t(
                          'A thread opens for each job once you submit it.',
                        ),
                      ),
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
                      return InterioBeeCard(
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
  ConsumerState<ServiceThreadScreen> createState() =>
      _ServiceThreadScreenState();
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
          .read(customerApiProvider)
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
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
            const Text('Decora Shine'),
            Text(
              context.t('about your {trade}', {
                'trade': widget.title.toLowerCase(),
              }),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
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
                context.t(
                  'Your coordinator reads this and passes anything relevant to '
                  'the professionals quoting for you.',
                ),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: AsyncView(
                value: thread,
                onRetry: () =>
                    ref.invalidate(serviceThreadProvider(widget.leadDomainId)),
                data: (messages) => messages.isEmpty
                    ? EmptyState(
                        title: context.t('Nothing yet'),
                        body: context.t('Ask us anything about your job.'),
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
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: Space.xs),
                              padding: const EdgeInsets.all(Space.sm),
                              constraints: const BoxConstraints(maxWidth: 300),
                              decoration: BoxDecoration(
                                color: mine
                                    ? context.colors.surfaceContainerHighest
                                    : InterioBeeColors.chalk,
                                borderRadius: Radii.panelRadius,
                                border: Border.all(
                                  color: context.palette.hairline,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: mine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mine ? context.t('You') : 'Decora Shine',
                                    style: context.text.labelMedium?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: Space.xxs),
                                  Text(
                                    message.body,
                                    style: context.text.bodyMedium,
                                  ),
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
                      decoration: InputDecoration(
                        hintText: context.t('Message Decora Shine'),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: Space.xs),
                  FilledButton(
                    onPressed: _body.text.trim().isEmpty || _sending
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

class _AccountTab extends ConsumerWidget {
  const _AccountTab({this.onSignOut, this.onSignIn});

  final VoidCallback? onSignOut;

  /// Non-null exactly when nobody is signed in.
  ///
  /// This is the "login button" in the ordinary sense — always in the same
  /// place, always reachable, and never in anybody's way.
  final Future<bool> Function()? onSignIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = onSignIn == null;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            const SizedBox(height: Space.md),
            Text(context.t('Account'), style: context.text.headlineLarge),
            const SizedBox(height: Space.md),

            /// Signed out, this is the only thing above the public pages.
            ///
            /// The five links below it are one person's own record, and a row
            /// that opens a screen saying "please try again" is worse than no
            /// row: it looks broken rather than locked.
            if (!signedIn) ...[
              InterioBeeCard(
                padding: const EdgeInsets.all(Space.cardPaddingWide),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('Sign in'),
                      style: context.text.headlineSmall,
                    ),
                    const SizedBox(height: Space.xxs),
                    Text(
                      context.t(
                        'Your number is your account. We send a code — there '
                        'is no password to remember.',
                      ),
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Space.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onSignIn,
                        child: Text(context.t('Sign in')),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.md),
            ],

            /// Five links, one guard.
            ///
            /// Every one of these opens a screen built entirely from `/me/*`,
            /// so signed out they lead to "Please try again" — which reads as
            /// broken rather than locked. Written as a single block precisely
            /// because the first attempt guarded the first and the last and
            /// left Progress, Notifications and Invite a friend showing.
            if (signedIn) ...[
              _Link(
                title: context.t('Agreements'),
                subtitle: context.t('Contracts to sign, and signed'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AgreementsScreen()),
                ),
              ),
              const SizedBox(height: Space.xs),
              _Link(
                title: context.t('Progress'),
                subtitle: context.t('Work under way'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProjectsScreen()),
                ),
              ),
              const SizedBox(height: Space.xs),
              _Link(
                title: context.t('Notifications'),
                subtitle: context.t('What we have told you'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: Space.xs),
              _Link(
                title: context.t('Invite a friend'),
                subtitle: context.t('Your code, and what it has earned'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReferralsScreen()),
                ),
              ),
              const SizedBox(height: Space.xs),
              _Link(
                title: context.t('Help'),
                subtitle: context.t('Ask us anything, a person answers'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SupportScreen()),
                ),
              ),
            ],

            const SizedBox(height: Space.xs),
            _Link(
              title: context.t('How it works'),
              subtitle: context.t('Seven steps, and who holds the money'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HowItWorksScreen(onStart: null),
                ),
              ),
            ),
            const SizedBox(height: Space.xs),
            _Link(
              title: context.t('Work with us'),
              subtitle: context.t('For carpenters, painters and fabricators'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => JoinAsProfessionalScreen(
                    /*
                     * Applying needs an account, because the application is
                     * attached to one — so a signed-out tradesperson is taken
                     * through sign-in first and lands on the form, rather than
                     * being told to come back later.
                     */
                    onApply: () async {
                      if (!signedIn) {
                        final ok = await onSignIn?.call() ?? false;
                        if (!ok || !context.mounted) return;
                      }
                      if (!context.mounted) return;
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BecomeProfessionalScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            /// The language switcher.
            ///
            /// Renders nothing when there is no `InterioBeeLanguageScope` above —
            /// a widget test pumping this tab alone, or the gallery.
            const SizedBox(height: Space.xs),
            const LanguageSetting(),

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
    return InterioBeeCard(
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

/// A square entry point. Two fit a 360dp row with the gutter intact.
class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InterioBeeCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Space.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: TapTarget.glyph, color: context.colors.primary),
          const SizedBox(height: Space.xs),
          Text(title, style: context.text.titleLarge),
          Text(
            subtitle,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The tap target that opens search.
///
/// A button dressed as a field rather than a real one: a live TextField here
/// would need its own controller, focus and debounce duplicated from
/// `SearchScreen`, and two search implementations drift.
class _SearchBar extends StatelessWidget {
  const _SearchBar({this.onStart});

  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return InterioBeeCard(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => SearchScreen(onStart: onStart))),
      child: Row(
        children: [
          Icon(Icons.search, color: context.colors.onSurfaceVariant),
          const SizedBox(width: Space.xs),
          Expanded(
            child: Text(
              context.t('Search everything'),
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
