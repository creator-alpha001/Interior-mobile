/// Shapes the API would send, built once so the tests read as assertions.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:dio/dio.dart';

/// An API that answers nothing. These tests render widgets from fixtures; the
/// screens that fetch are covered where the fetching is the point.
AanganApi fixtureApi() =>
    AanganApi.withDio(Dio(BaseOptions(baseUrl: 'https://test')));

const _city = City(
  id: 'city-1',
  name: 'Lucknow',
  slug: 'lucknow',
  state: 'Uttar Pradesh',
  isActive: true,
);

const _domain = Domain(
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
  deletedAt: null,
  id: 'domain-furniture',
  name: 'Furniture Work',
  slug: 'furniture',
  tagline: 'Made to fit',
  description: '',
  iconKey: 'chair',
  bannerUrl: null,
  defaultCommissionPercent: 12,
  isActive: true,
  sortOrder: 2,
  labels: DomainLabels(
    materials: 'Board & Hardware Brand',
    warranty: 'Warranty',
    pricingBasis: 'per running ft',
  ),
);

/// A masked client. There is no unmasked variant available to this package —
/// `boundaries_test.dart` asserts that.
MaskedClientSummary _client({String? address}) => MaskedClientSummary(
  displayName: 'Priya S.',
  city: _city,
  locality: 'Gomti Nagar',
  address: address,
  contactReleased: false,
);

VendorLeadCard fixtureLead({
  int competingQuotes = 2,
  int? budgetMax = 250000,
  Quote? myQuote,
}) {
  return VendorLeadCard(
    assignment: const LeadDomainAssignment(
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
      deletedAt: null,
      id: 'assign-1',
      leadDomainId: 'ld-1',
      professionalId: 'p1',
      responseStatus: AssignmentResponse.accepted,
      assignedAt: '2026-01-01T00:00:00.000Z',
      respondedAt: null,
      rejectionReason: null,
    ),
    leadDomain: const LeadDomain(
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
      deletedAt: null,
      id: 'ld-1',
      leadId: 'lead-1',
      domainId: 'domain-furniture',
      materialSource: MaterialSource.vendorSupplied,
      status: LeadDomainStatus.assigned,
      preferredProfessionalId: null,
      preferenceUnmetReason: null,
      selectedProfessionalId: null,
      selectedQuoteId: null,
    ),
    domain: _domain,
    leadReference: 'LD-1042',
    client: _client(),
    description: 'Wardrobe for the master bedroom, floor to ceiling.',
    urgency: 'within_month',
    materialSource: MaterialSource.vendorSupplied,
    items: const [],
    brief: null,
    siteNotes: const [],
    budgetMax: budgetMax,
    myQuote: myQuote,
    visits: const [],
    unreadMessages: 0,
    competingQuotes: competingQuotes,
    won: false,
    lost: false,
  );
}

ProjectMilestone fixtureMilestone({
  MilestoneVerification verification = MilestoneVerification.notStarted,
  String? verifierNote,
}) {
  return ProjectMilestone(
    id: 'stage-1',
    title: 'Carcass fitted',
    description: 'Frame in place and levelled.',
    completedAt: null,
    proof: const [],
    proofNote: null,
    submittedAt: null,
    verification: verification,
    verifiedAt: null,
    verifiedByUserId: null,
    verifierNote: verifierNote,
  );
}

VendorProjectView fixtureProject({List<ProjectMilestone>? milestones}) {
  return VendorProjectView(
    project: Project(
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
      deletedAt: null,
      id: 'project-1',
      reference: 'PR-2201',
      leadDomainId: 'ld-1',
      agreementId: 'ag-1',
      clientId: 'c1',
      professionalId: 'p1',
      quoteId: 'q1',
      value: 450000,
      commissionPercent: 12,
      commissionAmount: 54000,
      startDate: null,
      estimatedEndDate: null,
      actualEndDate: null,
      completionPercent: 25,
      status: ProjectStatus.ongoing,
      milestones: milestones ?? [fixtureMilestone()],
    ),
    domain: _domain,
    client: _client(),
    cityName: 'Lucknow',
    review: null,
  );
}

VendorVisitView fixtureVisit({
  String? address,
  MeetingStatus status = MeetingStatus.scheduled,
}) {
  return VendorVisitView(
    meeting: Meeting(
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
      deletedAt: null,
      id: 'meet-1',
      leadDomainId: 'ld-1',
      professionalId: 'p1',
      type: MeetingType.siteVisit,
      scheduledAt: '2026-09-12T10:30:00.000Z',
      location: 'Gomti Nagar',
      status: status,
      notes: null,
      coordinatorId: null,
      addressReleasedAt: address == null ? null : '2026-09-10T00:00:00.000Z',
      rescheduleRequestedAt: null,
      rescheduleNote: null,
      outcome: null,
      outcomeRecordedAt: null,
      outcomeChangedScope: false,
    ),
    domain: _domain,
    client: _client(address: address),
    leadReference: 'LD-1042',
  );
}
