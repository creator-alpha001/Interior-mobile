// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'ops_set_ticket_status_body_status.dart';

part 'ops_set_ticket_status_body.freezed.dart';
part 'ops_set_ticket_status_body.g.dart';

@Freezed()
abstract class OpsSetTicketStatusBody with _$OpsSetTicketStatusBody {
  const factory OpsSetTicketStatusBody({
    required OpsSetTicketStatusBodyStatus status,
  }) = _OpsSetTicketStatusBody;

  factory OpsSetTicketStatusBody.fromJson(Map<String, Object?> json) =>
      _$OpsSetTicketStatusBodyFromJson(json);
}
