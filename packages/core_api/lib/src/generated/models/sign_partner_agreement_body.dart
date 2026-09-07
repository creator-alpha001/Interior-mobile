// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_partner_agreement_body.freezed.dart';
part 'sign_partner_agreement_body.g.dart';

@Freezed()
abstract class SignPartnerAgreementBody with _$SignPartnerAgreementBody {
  const factory SignPartnerAgreementBody({
    required String signatoryName,
    required String signatoryRole,
    required String signatureText,
    required List<String> acknowledgedClauses,
  }) = _SignPartnerAgreementBody;
  
  factory SignPartnerAgreementBody.fromJson(Map<String, Object?> json) => _$SignPartnerAgreementBodyFromJson(json);
}
