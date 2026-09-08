// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'support_ticket_category.dart';
import 'support_ticket_priority.dart';
import 'support_ticket_status.dart';
import 'ticket_reply.dart';

part 'support_ticket.freezed.dart';
part 'support_ticket.g.dart';

@Freezed()
abstract class SupportTicket with _$SupportTicket {
  const factory SupportTicket({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String reference,
    required String raisedByUserId,
    required String? leadId,
    required String? projectId,
    required SupportTicketCategory category,
    required String subject,
    required String body,
    required SupportTicketPriority priority,
    required SupportTicketStatus status,
    required String? assignedToUserId,
    required List<TicketReply> replies,
  }) = _SupportTicket;

  factory SupportTicket.fromJson(Map<String, Object?> json) =>
      _$SupportTicketFromJson(json);
}
