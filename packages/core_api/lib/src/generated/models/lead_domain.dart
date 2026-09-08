// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'lead_domain_status.dart';
import 'material_source.dart';

part 'lead_domain.freezed.dart';
part 'lead_domain.g.dart';

@Freezed()
abstract class LeadDomain with _$LeadDomain {
  const factory LeadDomain({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String leadId,
    required String domainId,
    required MaterialSource materialSource,
    required LeadDomainStatus status,
    required String? preferredProfessionalId,
    required String? preferenceUnmetReason,
    required String? selectedProfessionalId,
    required String? selectedQuoteId,
  }) = _LeadDomain;

  factory LeadDomain.fromJson(Map<String, Object?> json) =>
      _$LeadDomainFromJson(json);
}
