// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'meeting_status.dart';
import 'meeting_type.dart';

part 'meeting.freezed.dart';
part 'meeting.g.dart';

@Freezed()
abstract class Meeting with _$Meeting {
  const factory Meeting({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String leadDomainId,
    required String professionalId,
    required MeetingType type,
    required String scheduledAt,
    required String location,
    required MeetingStatus status,
    required String? notes,
    required String? coordinatorId,
    required String? addressReleasedAt,
    required String? rescheduleRequestedAt,
    required String? rescheduleNote,
    required String? outcome,
    required String? outcomeRecordedAt,
    required bool outcomeChangedScope,
  }) = _Meeting;

  factory Meeting.fromJson(Map<String, Object?> json) =>
      _$MeetingFromJson(json);
}
