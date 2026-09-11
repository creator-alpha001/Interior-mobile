// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'city.dart';
import 'domain.dart';
import 'meeting.dart';
import 'professional_summary.dart';

part 'ops_visit_row.freezed.dart';
part 'ops_visit_row.g.dart';

@Freezed()
abstract class OpsVisitRow with _$OpsVisitRow {
  const factory OpsVisitRow({
    required Meeting meeting,
    required ProfessionalSummary professional,
    required String leadId,
    required String leadReference,
    required Domain domain,
    required City city,
  }) = _OpsVisitRow;

  factory OpsVisitRow.fromJson(Map<String, Object?> json) =>
      _$OpsVisitRowFromJson(json);
}
