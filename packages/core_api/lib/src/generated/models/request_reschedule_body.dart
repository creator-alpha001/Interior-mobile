// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_reschedule_body.freezed.dart';
part 'request_reschedule_body.g.dart';

@Freezed()
abstract class RequestRescheduleBody with _$RequestRescheduleBody {
  const factory RequestRescheduleBody({@Default('') String note}) =
      _RequestRescheduleBody;

  factory RequestRescheduleBody.fromJson(Map<String, Object?> json) =>
      _$RequestRescheduleBodyFromJson(json);
}
