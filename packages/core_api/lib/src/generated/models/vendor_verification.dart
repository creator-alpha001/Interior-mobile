// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_asset.dart';
import 'partner_agreement.dart';
import 'partner_terms.dart';
import 'vendor_document_slot.dart';
import 'verification_status.dart';

part 'vendor_verification.freezed.dart';
part 'vendor_verification.g.dart';

@Freezed()
abstract class VendorVerification with _$VendorVerification {
  const factory VendorVerification({
    required String professionalId,
    required VerificationStatus verificationStatus,
    required bool canBeVerified,
    required List<String> outstanding,
    required bool agreementComplete,
    required String? documentsDueBy,
    required bool documentsOverdue,
    required PartnerTerms terms,
    required PartnerAgreement? agreement,
    required List<MediaAsset> signedCopy,
    required List<VendorDocumentSlot> documents,
  }) = _VendorVerification;

  factory VendorVerification.fromJson(Map<String, Object?> json) =>
      _$VendorVerificationFromJson(json);
}
