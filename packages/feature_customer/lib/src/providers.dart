/// The customer shell's reads, and what a write invalidates.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supplied by the app at startup. Overridden in tests with a stubbed client.
///
/// Named for its shell rather than called `apiProvider`, because the vendor
/// package declares one too. When both were called `apiProvider`, `main.dart`
/// imported both packages, overrode the name that happened to win the import,
/// and every customer screen threw `apiProvider must be overridden` — behind
/// an error state that said only "Please try again".
///
/// The two stay separate on purpose: MOBILE.md §2 wants splitting into two
/// binaries to be a build flavour rather than a rewrite, which only holds while
/// neither feature package reaches into the other. Distinct names are what make
/// that separation safe instead of a trap.
final customerApiProvider = Provider<AanganApi>(
  (ref) => throw UnimplementedError('customerApiProvider must be overridden'),
);

ClientClient _me(Ref ref) => ref.watch(customerApiProvider).customer;
PublicClient _public(Ref ref) => ref.watch(customerApiProvider).public;

/* ---------------- the public surface, for browsing ---------------- */

final domainsProvider = FutureProvider<List<Domain>>(
  (ref) => _public(ref).listDomains().orThrow(),
);

final citiesProvider = FutureProvider<List<City>>(
  (ref) => _public(ref).listCities().orThrow(),
);

/// What the directory is currently showing.
///
/// Trade and city, as the web's `/professionals?domain=&city=` carries them in
/// the query string. Two fields rather than two providers, so setting both in
/// one gesture is one fetch.
@immutable
class ProfessionalFilters {
  const ProfessionalFilters({this.domainSlug, this.cityId});

  final String? domainSlug;
  final String? cityId;

  @override
  bool operator ==(Object other) =>
      other is ProfessionalFilters &&
      other.domainSlug == domainSlug &&
      other.cityId == cityId;

  @override
  int get hashCode => Object.hash(domainSlug, cityId);
}

final professionalFiltersProvider = StateProvider<ProfessionalFilters>(
  (ref) => const ProfessionalFilters(),
);

/// The directory, filtered as the web filters it.
///
/// `domain` is what makes `ProfessionalSummary.domainRating` come back
/// populated, which is the whole argument for the filter existing: with no
/// trade selected the card can only show an average across every trade, and an
/// average across every trade is the wrong number to rank a carpenter by.
///
/// `verifiedOnly` matches the web and the empty state this screen already
/// wrote — an unverified professional is in no pool and belongs in no list a
/// customer reads.
final professionalsProvider = FutureProvider<GetProfessionalsResponse>((ref) {
  final filters = ref.watch(professionalFiltersProvider);
  return _public(ref)
      .listProfessionals(
        domain: filters.domainSlug,
        city: filters.cityId,
        verifiedOnly: true,
        limit: 48,
      )
      .orThrow();
});

final bannersProvider = FutureProvider<List<Banner>>(
  (ref) => _public(ref).listBanners().orThrow(),
);

final testimonialsProvider = FutureProvider<List<Testimonial>>(
  (ref) => _public(ref).listTestimonials().orThrow(),
);

final platformStatsProvider = FutureProvider<PlatformStats>(
  (ref) => _public(ref).platformStats().orThrow(),
);

/// How many products and packages sit behind each trade.
///
/// The web puts these under the four trade cells, and they do real work: a
/// trade with a number beside it reads as something with depth behind it
/// rather than as a category heading.
final catalogueCountsProvider = FutureProvider<List<CatalogueCount>>(
  (ref) => _public(ref).catalogueCounts().orThrow(),
);

/* ---------------- what is mine ---------------- */

/// A requirement is **N service tracks**, not one thing.
///
/// `LeadView.domains` is the list that matters: each carries its own status,
/// quotes, visits and unread count, because assignment, quoting, agreements and
/// execution all hang off the service rather than the requirement.
final requirementsProvider = FutureProvider<List<LeadView>>(
  (ref) => _me(ref).listRequirements().orThrow(),
);

final requirementProvider = FutureProvider.family<LeadView, String>(
  (ref, id) => _me(ref).getRequirement(id: id).orThrow(),
);

final agreementsProvider = FutureProvider<List<AgreementView>>(
  (ref) => _me(ref).listAgreements().orThrow(),
);

final projectsProvider = FutureProvider<List<ProjectView>>(
  (ref) => _me(ref).listProjects().orThrow(),
);

final notificationsProvider = FutureProvider<List<Notification>>(
  (ref) => _me(ref).listNotifications().orThrow(),
);

final ticketsProvider = FutureProvider<List<SupportTicket>>(
  (ref) => _me(ref).listTickets().orThrow(),
);

final referralsProvider = FutureProvider<ReferralSummary>(
  (ref) => _me(ref).referrals().orThrow(),
);

/// One thread per service, and the platform is on the other side of it.
final serviceThreadProvider = FutureProvider.family<List<Message>, String>(
  (ref, leadDomainId) =>
      _me(ref).listServiceMessages(id: leadDomainId).orThrow(),
);

/// Everything a write could have changed.
///
/// Blunt on purpose: selecting a quote moves a requirement, may create an
/// agreement, and changes what the home screen says. Naming exactly what each
/// mutation touches is the version that goes wrong.
void refreshAfterWrite(WidgetRef ref) {
  ref
    ..invalidate(requirementsProvider)
    ..invalidate(agreementsProvider)
    ..invalidate(projectsProvider)
    ..invalidate(notificationsProvider);
}
