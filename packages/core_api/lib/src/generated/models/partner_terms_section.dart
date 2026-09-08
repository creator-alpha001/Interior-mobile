// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_terms_section.freezed.dart';
part 'partner_terms_section.g.dart';

@Freezed()
abstract class PartnerTermsSection with _$PartnerTermsSection {
  const factory PartnerTermsSection({
    required String heading,
    required String body,
  }) = _PartnerTermsSection;

  factory PartnerTermsSection.fromJson(Map<String, Object?> json) =>
      _$PartnerTermsSectionFromJson(json);
}
