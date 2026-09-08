// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'agreement_lead_domain.dart';
import 'domain.dart';
import 'quote.dart';

part 'agreement_line.freezed.dart';
part 'agreement_line.g.dart';

@Freezed()
abstract class AgreementLine with _$AgreementLine {
  const factory AgreementLine({
    required AgreementLeadDomain link,
    required Domain domain,
    required Quote quote,
  }) = _AgreementLine;

  factory AgreementLine.fromJson(Map<String, Object?> json) =>
      _$AgreementLineFromJson(json);
}
