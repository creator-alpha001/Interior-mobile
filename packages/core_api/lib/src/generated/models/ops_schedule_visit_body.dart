// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'meeting_type.dart';

part 'ops_schedule_visit_body.freezed.dart';
part 'ops_schedule_visit_body.g.dart';

@Freezed()
abstract class OpsScheduleVisitBody with _$OpsScheduleVisitBody {
  const factory OpsScheduleVisitBody({
    required String professionalId,
    required DateTime scheduledAt,
    required MeetingType type,
    String? notes,
  }) = _OpsScheduleVisitBody;

  factory OpsScheduleVisitBody.fromJson(Map<String, Object?> json) =>
      _$OpsScheduleVisitBodyFromJson(json);
}
