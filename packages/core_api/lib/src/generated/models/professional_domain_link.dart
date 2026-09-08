// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';
import 'professional_domain.dart';

part 'professional_domain_link.freezed.dart';
part 'professional_domain_link.g.dart';

@Freezed()
abstract class ProfessionalDomainLink with _$ProfessionalDomainLink {
  const factory ProfessionalDomainLink({
    required ProfessionalDomain link,
    required Domain domain,
  }) = _ProfessionalDomainLink;

  factory ProfessionalDomainLink.fromJson(Map<String, Object?> json) =>
      _$ProfessionalDomainLinkFromJson(json);
}
