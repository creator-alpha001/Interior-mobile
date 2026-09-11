// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/add_achievement_body.dart';
import '../models/add_portfolio_item_body.dart';
import '../models/lead_filter.dart';
import '../models/message.dart';
import '../models/ok.dart';
import '../models/partner_agreement.dart';
import '../models/portfolio_item.dart';
import '../models/quote.dart';
import '../models/report_hardcopy_body.dart';
import '../models/respond_to_lead_body.dart';
import '../models/send_service_message_body.dart';
import '../models/sign_partner_agreement_body.dart';
import '../models/submit_milestone_proof_body.dart';
import '../models/submit_quote_body.dart';
import '../models/submit_signed_copy_body.dart';
import '../models/submit_vendor_document_body.dart';
import '../models/vendor_achievement.dart';
import '../models/vendor_agreement_view.dart';
import '../models/vendor_dashboard.dart';
import '../models/vendor_invoice_view.dart';
import '../models/vendor_lead_card.dart';
import '../models/vendor_onboarding.dart';
import '../models/vendor_performance.dart';
import '../models/vendor_project_view.dart';
import '../models/vendor_verification.dart';
import '../models/vendor_visit_view.dart';

part 'professional_client.g.dart';

@RestApi()
abstract class ProfessionalClient {
  factory ProfessionalClient(Dio dio, {String? baseUrl}) = _ProfessionalClient;

  /// vendorLeads.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/leads')
  Future<List<VendorLeadCard>> vendorLeads({
    @Query('filter') LeadFilter? filter,
  });

  /// vendorLead.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/leads/{id}')
  Future<VendorLeadCard> vendorLead({@Path('id') required String id});

  /// respondToLead.
  ///
  /// Requires a signed-in professional.
  @POST('/vendor/leads/{id}/respond')
  Future<VendorLeadCard> respondToLead({
    @Path('id') required String id,
    @Body() required RespondToLeadBody body,
  });

  /// submitQuote.
  ///
  /// Requires a signed-in professional.
  @POST('/vendor/leads/{id}/quotes')
  Future<Quote> submitQuote({
    @Path('id') required String id,
    @Body() required SubmitQuoteBody body,
  });

  /// vendorThread.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/leads/{id}/messages')
  Future<List<Message>> vendorThread({@Path('id') required String id});

  /// sendVendorMessage.
  ///
  /// Requires a signed-in professional.
  @POST('/vendor/leads/{id}/messages')
  Future<Message> sendVendorMessage({
    @Path('id') required String id,
    @Body() required SendServiceMessageBody body,
  });

  /// vendorDashboard.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/dashboard')
  Future<VendorDashboard> vendorDashboard();

  /// vendorAgreements.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/agreements')
  Future<List<VendorAgreementView>> vendorAgreements();

  /// vendorProjects.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/projects')
  Future<List<VendorProjectView>> vendorProjects();

  /// submitMilestoneProof.
  ///
  /// Requires a signed-in professional.
  @POST('/vendor/projects/{id}/stages/{stageId}/proof')
  Future<List<VendorProjectView>> submitMilestoneProof({
    @Path('id') required String id,
    @Path('stageId') required String stageId,
    @Body() required SubmitMilestoneProofBody body,
  });

  /// vendorInvoices.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/invoices')
  Future<List<VendorInvoiceView>> vendorInvoices();

  /// vendorVisits.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/visits')
  Future<List<VendorVisitView>> vendorVisits();

  /// vendorPerformance.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/performance')
  Future<VendorPerformance> vendorPerformance();

  /// vendorPortfolio.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/portfolio')
  Future<List<PortfolioItem>> vendorPortfolio();

  /// addPortfolioItem.
  ///
  /// Requires a signed-in professional.
  @POST('/vendor/portfolio')
  Future<PortfolioItem> addPortfolioItem({
    @Body() required AddPortfolioItemBody body,
  });

  /// removePortfolioItem.
  ///
  /// Requires a signed-in professional.
  @DELETE('/vendor/portfolio/{id}')
  Future<Ok> removePortfolioItem({@Path('id') required String id});

  /// vendorAchievements.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/achievements')
  Future<List<VendorAchievement>> vendorAchievements();

  /// addAchievement.
  ///
  /// Requires a signed-in professional.
  @POST('/vendor/achievements')
  Future<VendorAchievement> addAchievement({
    @Body() required AddAchievementBody body,
  });

  /// removeAchievement.
  ///
  /// Requires a signed-in professional.
  @DELETE('/vendor/achievements/{id}')
  Future<Ok> removeAchievement({@Path('id') required String id});

  /// vendorOnboarding.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/onboarding')
  Future<VendorOnboarding> vendorOnboarding();

  /// signPartnerAgreement.
  ///
  /// Requires a signed-in professional.
  @POST('/vendor/onboarding/agreement')
  Future<PartnerAgreement> signPartnerAgreement({
    @Body() required SignPartnerAgreementBody body,
  });

  /// vendorVerification.
  ///
  /// Requires a signed-in professional.
  @GET('/vendor/verification')
  Future<VendorVerification> vendorVerification();

  /// submitSignedCopy.
  ///
  /// Requires a signed-in professional.
  @POST('/vendor/verification/signed-copy')
  Future<VendorVerification> submitSignedCopy({
    @Body() required SubmitSignedCopyBody body,
  });

  /// reportHardcopy.
  ///
  /// Requires a signed-in professional.
  @POST('/vendor/verification/hardcopy')
  Future<VendorVerification> reportHardcopy({
    @Body() required ReportHardcopyBody body,
  });

  /// submitVendorDocument.
  ///
  /// Requires a signed-in professional.
  @POST('/vendor/verification/documents')
  Future<VendorVerification> submitVendorDocument({
    @Body() required SubmitVendorDocumentBody body,
  });
}
