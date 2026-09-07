// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain_labels_input.dart';

part 'ops_create_domain_body.freezed.dart';
part 'ops_create_domain_body.g.dart';

@Freezed()
abstract class OpsCreateDomainBody with _$OpsCreateDomainBody {
  const factory OpsCreateDomainBody({
    required String name,
    required int defaultCommissionPercent,
    required DomainLabelsInput labels,
    @Default('')
    String tagline,
    @Default('')
    String description,
  }) = _OpsCreateDomainBody;
  
  factory OpsCreateDomainBody.fromJson(Map<String, Object?> json) => _$OpsCreateDomainBodyFromJson(json);
}
