// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'city.dart';
import 'domain.dart';
import 'professional_application.dart';

part 'professional_application_view.freezed.dart';
part 'professional_application_view.g.dart';

@Freezed()
abstract class ProfessionalApplicationView with _$ProfessionalApplicationView {
  const factory ProfessionalApplicationView({
    required ProfessionalApplication application,
    required String applicantName,
    required String? applicantMobile,
    required String? applicantEmail,
    required List<Domain> requestedDomains,
    required List<City> serviceCities,
    required int requirementsRaised,
  }) = _ProfessionalApplicationView;

  factory ProfessionalApplicationView.fromJson(Map<String, Object?> json) =>
      _$ProfessionalApplicationViewFromJson(json);
}
