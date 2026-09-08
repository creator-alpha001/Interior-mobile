// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'city.dart';
import 'domain.dart';
import 'domain_rating.dart';

part 'professional_summary.freezed.dart';
part 'professional_summary.g.dart';

@Freezed()
abstract class ProfessionalSummary with _$ProfessionalSummary {
  const factory ProfessionalSummary({
    required String id,
    required String name,
    required String companyName,
    required String? avatarUrl,
    required City city,
    required num experienceYears,
    required int completedProjects,
    required num avgRating,
    required int ratingCount,
    required List<String> languages,
    required bool isVerified,
    required num avgResponseHours,
    required List<Domain> domains,
    DomainRating? domainRating,
  }) = _ProfessionalSummary;

  factory ProfessionalSummary.fromJson(Map<String, Object?> json) =>
      _$ProfessionalSummaryFromJson(json);
}
