// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_ticket.freezed.dart';
part 'upload_ticket.g.dart';

@Freezed()
abstract class UploadTicket with _$UploadTicket {
  const factory UploadTicket({
    required String uploadUrl,
    required Map<String, String> headers,
    required String assetId,
    required String publicUrl,
  }) = _UploadTicket;

  factory UploadTicket.fromJson(Map<String, Object?> json) =>
      _$UploadTicketFromJson(json);
}
