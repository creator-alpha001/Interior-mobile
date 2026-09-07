// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'meeting.dart';
import 'professional_summary.dart';

part 'meeting_view.freezed.dart';
part 'meeting_view.g.dart';

@Freezed()
abstract class MeetingView with _$MeetingView {
  const factory MeetingView({
    required Meeting meeting,
    required ProfessionalSummary professional,
  }) = _MeetingView;
  
  factory MeetingView.fromJson(Map<String, Object?> json) => _$MeetingViewFromJson(json);
}
