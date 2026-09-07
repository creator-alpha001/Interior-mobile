// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain_labels_input.dart';

part 'ops_update_domain_body.freezed.dart';
part 'ops_update_domain_body.g.dart';

@Freezed()
abstract class OpsUpdateDomainBody with _$OpsUpdateDomainBody {
  const factory OpsUpdateDomainBody({
    @Default('')
    String tagline,
    @Default('')
    String description,
    String? name,
    int? defaultCommissionPercent,
    DomainLabelsInput? labels,
    bool? isActive,
  }) = _OpsUpdateDomainBody;
  
  factory OpsUpdateDomainBody.fromJson(Map<String, Object?> json) => _$OpsUpdateDomainBodyFromJson(json);
}
