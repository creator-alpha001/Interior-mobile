// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_professional_application_body.freezed.dart';
part 'submit_professional_application_body.g.dart';

@Freezed()
abstract class SubmitProfessionalApplicationBody
    with _$SubmitProfessionalApplicationBody {
  const factory SubmitProfessionalApplicationBody({
    required String companyName,
    required int experienceYears,
    required String bio,
    required String contactName,
    required List<String> requestedDomainIds,
    required List<String> serviceCityIds,
    @Default('') String serviceAreaNote,
    String? gstNumber,
    String? contactMobile,
  }) = _SubmitProfessionalApplicationBody;

  factory SubmitProfessionalApplicationBody.fromJson(
    Map<String, Object?> json,
  ) => _$SubmitProfessionalApplicationBodyFromJson(json);
}
