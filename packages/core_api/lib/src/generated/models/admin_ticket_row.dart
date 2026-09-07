// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'support_ticket.dart';

part 'admin_ticket_row.freezed.dart';
part 'admin_ticket_row.g.dart';

@Freezed()
abstract class AdminTicketRow with _$AdminTicketRow {
  const factory AdminTicketRow({
    required SupportTicket ticket,
    required String raisedByName,
    required String raisedByRole,
  }) = _AdminTicketRow;
  
  factory AdminTicketRow.fromJson(Map<String, Object?> json) => _$AdminTicketRowFromJson(json);
}
