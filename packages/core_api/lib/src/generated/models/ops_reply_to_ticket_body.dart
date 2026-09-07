// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ops_reply_to_ticket_body.freezed.dart';
part 'ops_reply_to_ticket_body.g.dart';

@Freezed()
abstract class OpsReplyToTicketBody with _$OpsReplyToTicketBody {
  const factory OpsReplyToTicketBody({
    required String body,
  }) = _OpsReplyToTicketBody;
  
  factory OpsReplyToTicketBody.fromJson(Map<String, Object?> json) => _$OpsReplyToTicketBodyFromJson(json);
}
