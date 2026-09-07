// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'verification_status.dart';

part 'professional.freezed.dart';
part 'professional.g.dart';

@Freezed()
abstract class Professional with _$Professional {
  const factory Professional({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String userId,
    required String companyName,
    required String? gstNumber,
    required num experienceYears,
    required String bio,
    required num avgRating,
    required int ratingCount,
    required int completedProjects,
    required List<String> languages,
    required VerificationStatus verificationStatus,
    required num avgResponseHours,
  }) = _Professional;
  
  factory Professional.fromJson(Map<String, Object?> json) => _$ProfessionalFromJson(json);
}
