// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'timeline_kind.dart';

part 'timeline_event.freezed.dart';
part 'timeline_event.g.dart';

@Freezed()
abstract class TimelineEvent with _$TimelineEvent {
  const factory TimelineEvent({
    required String id,
    required TimelineKind kind,
    required String at,
    required String title,
    required String? detail,
    required String? domainName,
    required String? actor,
  }) = _TimelineEvent;

  factory TimelineEvent.fromJson(Map<String, Object?> json) =>
      _$TimelineEventFromJson(json);
}
