// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'city.dart';
import 'client_summary.dart';
import 'lead.dart';
import 'lead_domain_view.dart';

part 'lead_view.freezed.dart';
part 'lead_view.g.dart';

@Freezed()
abstract class LeadView with _$LeadView {
  const factory LeadView({
    required Lead lead,
    required ClientSummary client,
    required City city,
    required List<LeadDomainView> domains,
    required List<String> domainNames,
    required bool isMultiDomain,
  }) = _LeadView;

  factory LeadView.fromJson(Map<String, Object?> json) =>
      _$LeadViewFromJson(json);
}
