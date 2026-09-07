// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'upload_purpose.dart';

part 'create_upload_ticket_body.freezed.dart';
part 'create_upload_ticket_body.g.dart';

@Freezed()
abstract class CreateUploadTicketBody with _$CreateUploadTicketBody {
  const factory CreateUploadTicketBody({
    required UploadPurpose purpose,
    required String fileName,
    required String contentType,
    required int sizeBytes,
  }) = _CreateUploadTicketBody;
  
  factory CreateUploadTicketBody.fromJson(Map<String, Object?> json) => _$CreateUploadTicketBodyFromJson(json);
}
