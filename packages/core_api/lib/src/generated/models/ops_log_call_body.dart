// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'ops_log_call_body_call_status.dart';

part 'ops_log_call_body.freezed.dart';
part 'ops_log_call_body.g.dart';

@Freezed()
abstract class OpsLogCallBody with _$OpsLogCallBody {
  const factory OpsLogCallBody({
    required OpsLogCallBodyCallStatus callStatus,
    String? followUpDate,
    @Default('')
    String remarks,
  }) = _OpsLogCallBody;
  
  factory OpsLogCallBody.fromJson(Map<String, Object?> json) => _$OpsLogCallBodyFromJson(json);
}
