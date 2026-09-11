// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'partner_acknowledgement.dart';
import 'partner_terms_section.dart';

part 'partner_terms.freezed.dart';
part 'partner_terms.g.dart';

@Freezed()
abstract class PartnerTerms with _$PartnerTerms {
  const factory PartnerTerms({
    required String version,
    required String effectiveFrom,
    required String title,
    required String summary,
    required List<PartnerTermsSection> sections,
    required List<PartnerAcknowledgement> acknowledgements,
    required String? documentUrl,
    required String hardcopyInstructions,
  }) = _PartnerTerms;

  factory PartnerTerms.fromJson(Map<String, Object?> json) =>
      _$PartnerTermsFromJson(json);
}
