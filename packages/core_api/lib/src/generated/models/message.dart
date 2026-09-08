// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'message_channel.dart';
import 'message_sender_role.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@Freezed()
abstract class Message with _$Message {
  const factory Message({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String leadDomainId,
    required MessageChannel channel,
    required MessageSenderRole senderRole,
    required String senderId,
    required String? professionalId,
    required String body,
    required String? attachmentUrl,
    required String? readAt,
    required String? relayedFromMessageId,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) =>
      _$MessageFromJson(json);
}
