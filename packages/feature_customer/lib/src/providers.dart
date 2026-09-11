/// The customer shell's reads, and what a write invalidates.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
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
final customerApiProvider = Provider<InterioBeeApi>(
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
/// Everything the web's `/professionals` carries in its query string: trade,
/// city, verification, a rating floor, an experience floor and the sort. One
/// object rather than six providers, so setting several in one sheet is one
/// fetch.
@immutable
class ProfessionalFilters {
  const ProfessionalFilters({
    this.domainSlug,
    this.cityId,
    this.verifiedOnly = false,
    this.minRating,
    this.minExperience,
    this.sort = Sort2.rating,
  });

  final String? domainSlug;
  final String? cityId;

  /// The customer's choice to see only badged professionals — never the
  /// default. Approved vendors are listed whether or not their paperwork is
  /// verified yet, and the badge says which, exactly as on the web.
  final bool verifiedOnly;

  final double? minRating;
  final int? minExperience;
  final Sort2 sort;

  ProfessionalFilters copyWith({
    Object? domainSlug = _keep,
    Object? cityId = _keep,
    bool? verifiedOnly,
    Object? minRating = _keep,
    Object? minExperience = _keep,
    Sort2? sort,
  }) {
    return ProfessionalFilters(
      domainSlug: domainSlug == _keep ? this.domainSlug : domainSlug as String?,
      cityId: cityId == _keep ? this.cityId : cityId as String?,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      minRating: minRating == _keep ? this.minRating : minRating as double?,
      minExperience: minExperience == _keep
          ? this.minExperience
          : minExperience as int?,
      sort: sort ?? this.sort,
    );
  }

  /// A sentinel, so `copyWith(cityId: null)` clears a filter rather than being
  /// indistinguishable from not passing it.
  static const _keep = Object();

  /// What the Filter button counts: the sheet's contents. Trade has its own
  /// row in view, and a sort is not a filter.
  int get activeCount =>
      [cityId, minRating, minExperience].where((v) => v != null).length +
      (verifiedOnly ? 1 : 0);

  @override
  bool operator ==(Object other) =>
      other is ProfessionalFilters &&
      other.domainSlug == domainSlug &&
      other.cityId == cityId &&
      other.verifiedOnly == verifiedOnly &&
      other.minRating == minRating &&
      other.minExperience == minExperience &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    domainSlug,
    cityId,
    verifiedOnly,
    minRating,
    minExperience,
    sort,
  );
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
/// `verifiedOnly` is sent only when the customer asks for it. It used to be
/// forced on, back when approval and verification were the same thing; since
/// vendor verification became its own step the web lists every approved
/// professional and badges the verified ones, and this matches it.
final professionalsProvider = FutureProvider<GetProfessionalsResponse>((ref) {
  final filters = ref.watch(professionalFiltersProvider);
  return _public(ref)
      .listProfessionals(
        domain: filters.domainSlug,
        city: filters.cityId,
        verifiedOnly: filters.verifiedOnly ? true : null,
        minRating: filters.minRating,
        minExperience: filters.minExperience,
        sort: filters.sort,
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

/// This account's request to become a vendor, or null if they never made one.
///
/// Null is the ordinary answer rather than an error — most customers never
/// apply — so the screen branches on it instead of treating it as a failure.
final professionalApplicationProvider =
    FutureProvider<ProfessionalApplicationView?>(
      (ref) => _me(ref).myProfessionalApplication().orThrow(),
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

/// **Everything that belonged to whoever was signed in.**
///
/// A `FutureProvider` keeps its resolved value for the life of the container,
/// and the container lives as long as the app. Signing out cleared the token
/// and the HTTP cache but left these — so signing in as somebody else on the
/// same handset showed the previous person's jobs, by reference number, until
/// something happened to invalidate them. Seen on a real device: a customer
/// with no requirements at all was shown two of another customer's.
///
/// Called on both edges — sign-in and sign-out — because either can change who
/// the data belongs to, and the flow that verifies a number *at the end* of the
/// requirement form only crosses the first one.
///
/// `customerSessionProviders` is the list, kept as a value rather than inlined here, so
/// `session_reset_test.dart` can scan this file and fail when a new per-session
/// provider is added without being added to it. That test is the only reason
/// this stays correct: the next provider will be written by somebody who has
/// never read this comment.
final customerSessionProviders = <ProviderOrFamily>[
  requirementsProvider,
  requirementProvider,
  agreementsProvider,
  projectsProvider,
  notificationsProvider,
  ticketsProvider,
  referralsProvider,
  serviceThreadProvider,
  professionalApplicationProvider,
];

void resetCustomerSession(ProviderContainer container) {
  for (final provider in customerSessionProviders) {
    container.invalidate(provider);
  }
}
