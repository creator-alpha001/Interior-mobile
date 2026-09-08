// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'city.dart';
import 'domain.dart';
import 'domain_rating.dart';
import 'portfolio_item.dart';
import 'professional.dart';
import 'professional_domain.dart';
import 'review_view.dart';
import 'user.dart';

part 'professional_profile.freezed.dart';
part 'professional_profile.g.dart';

@Freezed()
abstract class ProfessionalProfile with _$ProfessionalProfile {
  const factory ProfessionalProfile({
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
    required Professional professional,
    required User user,
    required String bio,
    required List<ProfessionalDomain> domainStats,
    required List<City> serviceCities,
    required List<PortfolioItem> portfolio,
    required List<ReviewView> reviews,
    DomainRating? domainRating,
  }) = _ProfessionalProfile;

  factory ProfessionalProfile.fromJson(Map<String, Object?> json) =>
      _$ProfessionalProfileFromJson(json);
}
