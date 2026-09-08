// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ops_visit_outcome_body.freezed.dart';
part 'ops_visit_outcome_body.g.dart';

@Freezed()
abstract class OpsVisitOutcomeBody with _$OpsVisitOutcomeBody {
  const factory OpsVisitOutcomeBody({
    required String outcome,
    @Default(false) bool changedScope,
  }) = _OpsVisitOutcomeBody;

  factory OpsVisitOutcomeBody.fromJson(Map<String, Object?> json) =>
      _$OpsVisitOutcomeBodyFromJson(json);
}
