/// Shapes the API would send, built once so the tests read as assertions.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:dio/dio.dart';

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

/// The customer's own summary. They see their own contact details; nobody
/// else's ever reaches this app.
const _client = ClientSummary(
  id: 'c1',
  userId: 'u1',
  name: 'Priya Sharma',
  mobile: '919839012477',
  email: null,
  city: _city,
  address: null,
);

/// Carries `domainRating`, which is the whole point on the comparison screen.
ProfessionalSummary _professional({String id = 'p1', String name = 'Meher Interiors'}) =>
    ProfessionalSummary(
      id: id,
      name: name,
      companyName: name,
      avatarUrl: null,
      city: _city,
      experienceYears: 9,
      completedProjects: 31,
      avgRating: 4.1,
      ratingCount: 40,
      languages: const [],
      isVerified: true,
      avgResponseHours: 3,
      domains: const [_domain],
      domainRating: const DomainRating(
        domainId: 'domain-furniture',
        avgRating: 4.6,
        ratingCount: 22,
      ),
    );

Quote _quote({String id = 'q1', int total = 450000}) => Quote(
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
      deletedAt: null,
      id: id,
      leadDomainId: 'ld-1',
      professionalId: 'p1',
      version: 1,
      supersedesQuoteId: null,
      lineItems: const [],
      subtotal: total,
      taxPercent: 18,
      taxAmount: 0,
      total: total,
      timelineDays: 30,
      warrantyMonths: 12,
      warrantyDetails: '',
      materialsSummary: '',
      boqUrl: null,
      quotePdfUrl: null,
      status: QuoteStatus.submitted,
      notes: null,
    );

QuoteView fixtureQuoteView({String quoteId = 'q1', int total = 450000}) =>
    QuoteView(
      quote: _quote(id: quoteId, total: total),
      professional: _professional(id: quoteId == 'q1' ? 'p1' : 'p2'),
      domain: _domain,
    );

LeadDomainView fixtureService({
  List<QuoteView> quotes = const [],
  String? selectedQuoteId,
}) =>
    LeadDomainView(
      leadDomain: LeadDomain(
        createdAt: '2026-01-01T00:00:00.000Z',
        updatedAt: '2026-01-01T00:00:00.000Z',
        deletedAt: null,
        id: 'ld-1',
        leadId: 'lead-1',
        domainId: 'domain-furniture',
        materialSource: MaterialSource.vendorSupplied,
        status: LeadDomainStatus.quoted,
        preferredProfessionalId: null,
        preferenceUnmetReason: null,
        selectedProfessionalId: null,
        selectedQuoteId: selectedQuoteId,
      ),
      domain: _domain,
      assignments: const [],
      quotes: quotes,
      meetings: const [],
      items: const [],
      selectedProfessional: null,
      unreadMessages: 0,
    );

ProjectMilestone fixtureMilestone({
  MilestoneVerification verification = MilestoneVerification.notStarted,
  String? verifierNote,
}) =>
    ProjectMilestone(
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

ProjectView fixtureProjectView({List<ProjectMilestone>? milestones}) => ProjectView(
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
      professional: _professional(),
      client: _client,
      review: null,
    );
