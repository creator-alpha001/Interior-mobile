// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain_approval_status.dart';

part 'professional_domain.freezed.dart';
part 'professional_domain.g.dart';

@Freezed()
abstract class ProfessionalDomain with _$ProfessionalDomain {
  const factory ProfessionalDomain({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String professionalId,
    required String domainId,
    required DomainApprovalStatus verificationStatus,
    required num? commissionPercentOverride,
    required num avgRating,
    required num ratingCount,
    required num completedProjects,
  }) = _ProfessionalDomain;
  
  factory ProfessionalDomain.fromJson(Map<String, Object?> json) => _$ProfessionalDomainFromJson(json);
}
