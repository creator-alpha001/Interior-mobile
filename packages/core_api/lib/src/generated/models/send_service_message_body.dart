// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_service_message_body.freezed.dart';
part 'send_service_message_body.g.dart';

@Freezed()
abstract class SendServiceMessageBody with _$SendServiceMessageBody {
  const factory SendServiceMessageBody({
    required String body,
  }) = _SendServiceMessageBody;
  
  factory SendServiceMessageBody.fromJson(Map<String, Object?> json) => _$SendServiceMessageBodyFromJson(json);
}
