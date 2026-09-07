// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'partner_agreement_status.dart';

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
  }) = _PartnerAgreement;
  
  factory PartnerAgreement.fromJson(Map<String, Object?> json) => _$PartnerAgreementFromJson(json);
}
