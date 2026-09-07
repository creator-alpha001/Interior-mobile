/// The customer shell's reads, and what a write invalidates.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supplied by the app at startup. Overridden in tests with a stubbed client.
final apiProvider = Provider<AanganApi>(
  (ref) => throw UnimplementedError('apiProvider must be overridden'),
);

ClientClient _me(Ref ref) => ref.watch(apiProvider).customer;
PublicClient _public(Ref ref) => ref.watch(apiProvider).public;

/* ---------------- the public surface, for browsing ---------------- */

final domainsProvider = FutureProvider<List<Domain>>(
  (ref) => _public(ref).listDomains().orThrow(),
);

final citiesProvider = FutureProvider<List<City>>(
  (ref) => _public(ref).listCities().orThrow(),
);

final professionalsProvider = FutureProvider<GetProfessionalsResponse>(
  (ref) => _public(ref).listProfessionals().orThrow(),
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
  (ref, leadDomainId) => _me(ref).listServiceMessages(id: leadDomainId).orThrow(),
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
