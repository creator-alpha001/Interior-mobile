/// Every read the vendor shell makes, and what invalidates it.
///
/// MOBILE.md §4.2 picks Riverpod for this shape: nearly every screen here is
/// one or two remote reads, which is what a `FutureProvider` is, and provider
/// invalidation is how a mutation refreshes the lists behind it. That second
/// half is the part worth getting right — submitting a quote has to change the
/// lead card, the leads list *and* the dashboard counters, and none of those
/// screens should have to know the others exist.
///
/// [refreshAfterWrite] is where that lives. Every mutation goes through it.
library;

import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/widgets.dart';
import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supplied by the app at startup. Overridden in tests with a stubbed client.
/// See the note on `customerApiProvider`: the two are named apart because
/// sharing a name cost the customer half of the app its API client.
final vendorApiProvider = Provider<AanganApi>(
  (ref) => throw UnimplementedError('vendorApiProvider must be overridden'),
);

ProfessionalClient _vendor(Ref ref) => ref.watch(vendorApiProvider).vendor;

/* ------------------------------------------------------------------ *
 * The gate
 * ------------------------------------------------------------------ */

/// Seven steps, and whether they are done.
///
/// Read before the shell renders anything: an unsigned professional is in no
/// lead pool however verified they are, so a dashboard is the wrong first
/// screen for them.
final onboardingProvider = FutureProvider<VendorOnboarding>(
  (ref) => _vendor(ref).vendorOnboarding().orThrow(),
);

/* ------------------------------------------------------------------ *
 * The shell
 * ------------------------------------------------------------------ */

final dashboardProvider = FutureProvider<VendorDashboard>(
  (ref) => _vendor(ref).vendorDashboard().orThrow(),
);

/// The tabs across the leads screen.
///
/// `LeadFilter` itself is generated from the contract, so the set of filters
/// cannot drift from what the API accepts — a sixth one added server-side turns
/// up here as a value this list does not cover, rather than as a 422 nobody
/// sees until a vendor taps it. Only the labels are ours.
///
/// `$unknown` is the generator's catch-all for a value this build predates. It
/// is excluded: offering a tab whose meaning this version does not know is
/// worse than not offering it.
/// The tabs, in order. A list rather than a map now that the labels are not
/// constants: the order is the part that has to be pinned, and the wording is
/// looked up per build.
const leadFilters = <LeadFilter>[
  LeadFilter.all,
  LeadFilter.valueNew,
  LeadFilter.quoting,
  LeadFilter.won,
  LeadFilter.lost,
];

String leadFilterLabel(BuildContext context, LeadFilter filter) =>
    switch (filter) {
      LeadFilter.all => context.t('All'),
      LeadFilter.valueNew => context.t('New'),
      LeadFilter.quoting => context.t('Quoting'),
      LeadFilter.won => context.t('Won'),
      LeadFilter.lost => context.t('Lost'),
      // Unreachable: `leadFilters` above does not offer it. Present because a
      // switch over a generated enum must be exhaustive.
      LeadFilter.$unknown => context.t('All'),
    };

final leadFilterProvider = StateProvider<LeadFilter>((ref) => LeadFilter.all);

final leadsProvider = FutureProvider<List<VendorLeadCard>>((ref) {
  final filter = ref.watch(leadFilterProvider);
  return _vendor(ref).vendorLeads(filter: filter).orThrow();
});

final leadProvider = FutureProvider.family<VendorLeadCard, String>(
  (ref, id) => _vendor(ref).vendorLead(id: id).orThrow(),
);

final threadProvider = FutureProvider.family<List<Message>, String>(
  (ref, leadDomainId) => _vendor(ref).vendorThread(id: leadDomainId).orThrow(),
);

final projectsProvider = FutureProvider<List<VendorProjectView>>(
  (ref) => _vendor(ref).vendorProjects().orThrow(),
);

final visitsProvider = FutureProvider<List<VendorVisitView>>(
  (ref) => _vendor(ref).vendorVisits().orThrow(),
);

final invoicesProvider = FutureProvider<List<VendorInvoiceView>>(
  (ref) => _vendor(ref).vendorInvoices().orThrow(),
);

final performanceProvider = FutureProvider<VendorPerformance>(
  (ref) => _vendor(ref).vendorPerformance().orThrow(),
);

final portfolioProvider = FutureProvider<List<PortfolioItem>>(
  (ref) => _vendor(ref).vendorPortfolio().orThrow(),
);

final agreementsProvider = FutureProvider<List<VendorAgreementView>>(
  (ref) => _vendor(ref).vendorAgreements().orThrow(),
);

/* ------------------------------------------------------------------ *
 * Refreshing
 * ------------------------------------------------------------------ */

/// What a write invalidates.
///
/// Deliberately blunt: after any mutation, every list that could have changed
/// is dropped and re-read. The alternative — each call site naming exactly what
/// it touched — is the version that goes wrong, because the thing somebody
/// forgets is always the counter on a screen they were not looking at.
///
/// These are cheap reads on a small payload, and a vendor performs perhaps
/// twenty writes a day.
void refreshAfterWrite(Ref ref) {
  ref
    ..invalidate(dashboardProvider)
    ..invalidate(leadsProvider)
    ..invalidate(projectsProvider)
    ..invalidate(visitsProvider)
    ..invalidate(invoicesProvider)
    ..invalidate(performanceProvider);
}

/// The same, from a widget.
void refreshAfterWriteFrom(WidgetRef ref) {
  ref
    ..invalidate(dashboardProvider)
    ..invalidate(leadsProvider)
    ..invalidate(projectsProvider)
    ..invalidate(visitsProvider)
    ..invalidate(invoicesProvider)
    ..invalidate(performanceProvider);
}

/// **Everything that belonged to whoever was signed in.**
///
/// The same hole as the customer side, and worse here: a vendor's leads carry
/// masked client summaries and localities, and their invoices are their
/// pipeline. A `FutureProvider` holds its value for the life of the container,
/// which is the life of the app — so signing out and in as a different
/// professional on a shared handset left the first one's leads on screen.
///
/// The list is a value, not an inline sequence, so `session_reset_test.dart`
/// can scan this file and fail when a provider built on `_vendor(ref)` is not
/// in it. Both shells are checked by the same test.
final vendorSessionProviders = <ProviderOrFamily>[
  onboardingProvider,
  dashboardProvider,
  leadsProvider,
  leadProvider,
  threadProvider,
  projectsProvider,
  visitsProvider,
  invoicesProvider,
  performanceProvider,
  portfolioProvider,
  agreementsProvider,
];

void resetVendorSession(ProviderContainer container) {
  for (final provider in vendorSessionProviders) {
    container.invalidate(provider);
  }
}
