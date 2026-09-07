// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'ticket_reply_author_role.dart';

part 'ticket_reply.freezed.dart';
part 'ticket_reply.g.dart';

@Freezed()
abstract class TicketReply with _$TicketReply {
  const factory TicketReply({
    required String id,
    required TicketReplyAuthorRole authorRole,
    required String authorName,
    required String body,
    required String createdAt,
  }) = _TicketReply;
  
  factory TicketReply.fromJson(Map<String, Object?> json) => _$TicketReplyFromJson(json);
}
