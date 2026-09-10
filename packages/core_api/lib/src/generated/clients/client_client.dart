// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/agreement.dart';
import '../models/agreement_view.dart';
import '../models/count.dart';
import '../models/create_requirement_body.dart';
import '../models/create_ticket_body.dart';
import '../models/lead_view.dart';
import '../models/meeting.dart';
import '../models/message.dart';
import '../models/notification.dart';
import '../models/professional_application_view.dart';
import '../models/project_view.dart';
import '../models/referral_summary.dart';
import '../models/request_reschedule_body.dart';
import '../models/review.dart';
import '../models/select_quote_body.dart';
import '../models/send_service_message_body.dart';
import '../models/submit_professional_application_body.dart';
import '../models/submit_review_body.dart';
import '../models/support_ticket.dart';
import '../models/ticket_reply.dart';

part 'client_client.g.dart';

@RestApi()
abstract class ClientClient {
  factory ClientClient(Dio dio, {String? baseUrl}) = _ClientClient;

  /// listRequirements.
  ///
  /// Requires a signed-in customer.
  @GET('/me/requirements')
  Future<List<LeadView>> listRequirements();

  /// createRequirement.
  ///
  /// Requires a signed-in customer.
  @POST('/me/requirements')
  Future<LeadView> createRequirement({
    @Body() required CreateRequirementBody body,
  });

  /// getRequirement.
  ///
  /// Requires a signed-in customer.
  @GET('/me/requirements/{id}')
  Future<LeadView> getRequirement({@Path('id') required String id});

  /// listServiceMessages.
  ///
  /// Requires a signed-in customer.
  @GET('/me/services/{id}/messages')
  Future<List<Message>> listServiceMessages({@Path('id') required String id});

  /// sendServiceMessage.
  ///
  /// Requires a signed-in customer.
  @POST('/me/services/{id}/messages')
  Future<Message> sendServiceMessage({
    @Path('id') required String id,
    @Body() required SendServiceMessageBody body,
  });

  /// selectQuote.
  ///
  /// Requires a signed-in customer.
  @POST('/me/services/{id}/select-quote')
  Future<LeadView> selectQuote({
    @Path('id') required String id,
    @Body() required SelectQuoteBody body,
  });

  /// listAgreements.
  ///
  /// Requires a signed-in customer.
  @GET('/me/agreements')
  Future<List<AgreementView>> listAgreements();

  /// generateAgreements.
  ///
  /// Requires a signed-in customer.
  @POST('/me/requirements/{id}/agreements')
  Future<List<AgreementView>> generateAgreements({
    @Path('id') required String id,
  });

  /// signAgreement.
  ///
  /// Requires a signed-in customer.
  @POST('/me/agreements/{id}/sign')
  Future<Agreement> signAgreement({@Path('id') required String id});

  /// listProjects.
  ///
  /// Requires a signed-in customer.
  @GET('/me/projects')
  Future<List<ProjectView>> listProjects();

  /// submitReview.
  ///
  /// Requires a signed-in customer.
  @POST('/me/reviews')
  Future<Review> submitReview({@Body() required SubmitReviewBody body});

  /// requestReschedule.
  ///
  /// Requires a signed-in customer.
  @POST('/me/visits/{id}/reschedule')
  Future<Meeting> requestReschedule({
    @Path('id') required String id,
    @Body() required RequestRescheduleBody body,
  });

  /// listNotifications.
  ///
  /// Requires a signed-in customer.
  @GET('/me/notifications')
  Future<List<Notification>> listNotifications();

  /// markNotificationsRead.
  ///
  /// Requires a signed-in customer.
  @POST('/me/notifications/read')
  Future<Count> markNotificationsRead();

  /// listTickets.
  ///
  /// Requires a signed-in customer.
  @GET('/me/tickets')
  Future<List<SupportTicket>> listTickets();

  /// createTicket.
  ///
  /// Requires a signed-in customer.
  @POST('/me/tickets')
  Future<SupportTicket> createTicket({@Body() required CreateTicketBody body});

  /// replyToTicket.
  ///
  /// Requires a signed-in customer.
  @POST('/me/tickets/{id}/replies')
  Future<TicketReply> replyToTicket({
    @Path('id') required String id,
    @Body() required SendServiceMessageBody body,
  });

  /// myProfessionalApplication.
  ///
  /// Requires a signed-in customer.
  @GET('/me/professional-application')
  Future<ProfessionalApplicationView?> myProfessionalApplication();

  /// submitProfessionalApplication.
  ///
  /// Requires a signed-in customer.
  @POST('/me/professional-application')
  Future<ProfessionalApplicationView> submitProfessionalApplication({
    @Body() required SubmitProfessionalApplicationBody body,
  });

  /// withdrawProfessionalApplication.
  ///
  /// Requires a signed-in customer.
  @DELETE('/me/professional-application')
  Future<ProfessionalApplicationView?> withdrawProfessionalApplication();

  /// referrals.
  ///
  /// Requires a signed-in customer.
  @GET('/me/referrals')
  Future<ReferralSummary> referrals();
}
