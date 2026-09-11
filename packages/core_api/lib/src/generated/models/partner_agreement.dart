// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'hardcopy_method.dart';
import 'hardcopy_status.dart';
import 'partner_agreement_status.dart';
import 'signed_copy_status.dart';

part 'partner_agreement.freezed.dart';
part 'partner_agreement.g.dart';

@Freezed()
abstract class PartnerAgreement with _$PartnerAgreement {
  const factory PartnerAgreement({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String professionalId,
    required String termsVersion,
    required PartnerAgreementStatus status,
    required String? signatureText,
    required String? signatoryName,
    required String? signatoryRole,
    required String? signedAt,
    required List<String> acknowledgedClauses,
    required String? signedFromIp,
    required String? signedUserAgent,
    required String? documentUrl,
    required SignedCopyStatus signedCopyStatus,
    required String? signedCopySubmittedAt,
    required String? stampCertificateNumber,
    required String? signedCopyReviewedAt,
    required String? signedCopyReviewedByUserId,
    required String? signedCopyReviewNote,
    required HardcopyMethod? hardcopyMethod,
    required HardcopyStatus hardcopyStatus,
    required String? hardcopyCourier,
    required String? hardcopyTrackingNumber,
    required String? hardcopyDispatchedAt,
    required String? hardcopyReceivedAt,
    required String? hardcopyReceivedByUserId,
    required String? hardcopyNote,
  }) = _PartnerAgreement;

  factory PartnerAgreement.fromJson(Map<String, Object?> json) =>
      _$PartnerAgreementFromJson(json);
}
