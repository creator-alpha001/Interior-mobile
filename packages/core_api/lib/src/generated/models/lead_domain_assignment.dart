// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'assignment_response.dart';

part 'lead_domain_assignment.freezed.dart';
part 'lead_domain_assignment.g.dart';

@Freezed()
abstract class LeadDomainAssignment with _$LeadDomainAssignment {
  const factory LeadDomainAssignment({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String leadDomainId,
    required String professionalId,
    required AssignmentResponse responseStatus,
    required String assignedAt,
    required String? respondedAt,
    required String? rejectionReason,
  }) = _LeadDomainAssignment;

  factory LeadDomainAssignment.fromJson(Map<String, Object?> json) =>
      _$LeadDomainAssignmentFromJson(json);
}
