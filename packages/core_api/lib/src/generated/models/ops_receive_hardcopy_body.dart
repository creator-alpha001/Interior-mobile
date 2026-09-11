// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'hardcopy_method.dart';

part 'ops_receive_hardcopy_body.freezed.dart';
part 'ops_receive_hardcopy_body.g.dart';

@Freezed()
abstract class OpsReceiveHardcopyBody with _$OpsReceiveHardcopyBody {
  const factory OpsReceiveHardcopyBody({
    required HardcopyMethod method,
    required String receivedOn,
    String? note,
  }) = _OpsReceiveHardcopyBody;

  factory OpsReceiveHardcopyBody.fromJson(Map<String, Object?> json) =>
      _$OpsReceiveHardcopyBodyFromJson(json);
}
