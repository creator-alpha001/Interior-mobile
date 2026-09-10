// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'professional_application_status.dart';

part 'professional_application.freezed.dart';
part 'professional_application.g.dart';

@Freezed()
abstract class ProfessionalApplication with _$ProfessionalApplication {
  const factory ProfessionalApplication({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String userId,
    required String companyName,
    required String? gstNumber,
    required int experienceYears,
    required String bio,
    required String contactName,
    required String? contactMobile,
    required List<String> requestedDomainIds,
    required List<String> serviceCityIds,
    required String serviceAreaNote,
    required ProfessionalApplicationStatus status,
    required String submittedAt,
    required String? decidedAt,
    required String? decidedByUserId,
    required String? reviewerNote,
    required String? professionalId,
  }) = _ProfessionalApplication;

  factory ProfessionalApplication.fromJson(Map<String, Object?> json) =>
      _$ProfessionalApplicationFromJson(json);
}
