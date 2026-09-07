// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'agreement_lead_domain.freezed.dart';
part 'agreement_lead_domain.g.dart';

@Freezed()
abstract class AgreementLeadDomain with _$AgreementLeadDomain {
  const factory AgreementLeadDomain({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String agreementId,
    required String leadDomainId,
    required String quoteId,
    required num value,
  }) = _AgreementLeadDomain;
  
  factory AgreementLeadDomain.fromJson(Map<String, Object?> json) => _$AgreementLeadDomainFromJson(json);
}
