// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'ops_decide_professional_application_body_approve_action.dart';
import 'ops_decide_professional_application_body_reject_action.dart';
import 'ops_decide_professional_application_body_request_changes_action.dart';
import 'ops_decide_professional_application_body_start_review_action.dart';

part 'ops_decide_professional_application_body.freezed.dart';
part 'ops_decide_professional_application_body.g.dart';

@Freezed(unionKey: 'action')
sealed class OpsDecideProfessionalApplicationBody
    with _$OpsDecideProfessionalApplicationBody {
  @FreezedUnionValue('start_review')
  const factory OpsDecideProfessionalApplicationBody.startReview({
    required OpsDecideProfessionalApplicationBodyStartReviewAction action,
  }) = OpsDecideProfessionalApplicationBodyStartReview;

  @FreezedUnionValue('request_changes')
  const factory OpsDecideProfessionalApplicationBody.requestChanges({
    required OpsDecideProfessionalApplicationBodyRequestChangesAction action,
    required String note,
  }) = OpsDecideProfessionalApplicationBodyRequestChanges;

  @FreezedUnionValue('reject')
  const factory OpsDecideProfessionalApplicationBody.reject({
    required OpsDecideProfessionalApplicationBodyRejectAction action,
    required String note,
  }) = OpsDecideProfessionalApplicationBodyReject;

  @FreezedUnionValue('approve')
  const factory OpsDecideProfessionalApplicationBody.approve({
    required OpsDecideProfessionalApplicationBodyApproveAction action,
    String? note,
    List<String>? approvedDomainIds,
    Map<String, int>? commissionPercentOverrides,
  }) = OpsDecideProfessionalApplicationBodyApprove;

  factory OpsDecideProfessionalApplicationBody.fromJson(
    Map<String, Object?> json,
  ) => _$OpsDecideProfessionalApplicationBodyFromJson(json);
}
