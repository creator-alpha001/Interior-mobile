// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'create_ticket_body_category.dart';

part 'create_ticket_body.freezed.dart';
part 'create_ticket_body.g.dart';

@Freezed()
abstract class CreateTicketBody with _$CreateTicketBody {
  const factory CreateTicketBody({
    required CreateTicketBodyCategory category,
    required String subject,
    required String body,
    String? leadId,
    String? projectId,
  }) = _CreateTicketBody;
  
  factory CreateTicketBody.fromJson(Map<String, Object?> json) => _$CreateTicketBodyFromJson(json);
}
