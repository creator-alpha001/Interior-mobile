// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ops_reply_to_client_body.freezed.dart';
part 'ops_reply_to_client_body.g.dart';

@Freezed()
abstract class OpsReplyToClientBody with _$OpsReplyToClientBody {
  const factory OpsReplyToClientBody({
    required String body,
    String? sourceMessageId,
  }) = _OpsReplyToClientBody;

  factory OpsReplyToClientBody.fromJson(Map<String, Object?> json) =>
      _$OpsReplyToClientBodyFromJson(json);
}
