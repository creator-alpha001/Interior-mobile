// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum AttentionKey {
  @JsonValue('new_leads')
  newLeads('new_leads'),
  @JsonValue('awaiting_reply')
  awaitingReply('awaiting_reply'),
  @JsonValue('unassigned_leads')
  unassignedLeads('unassigned_leads'),
  @JsonValue('follow_ups')
  followUps('follow_ups'),
  @JsonValue('applications')
  applications('applications'),
  @JsonValue('paperwork')
  paperwork('paperwork'),
  @JsonValue('trade_requests')
  tradeRequests('trade_requests'),
  @JsonValue('stage_proof')
  stageProof('stage_proof'),
  @JsonValue('visit_writeups')
  visitWriteups('visit_writeups'),
  @JsonValue('reschedules')
  reschedules('reschedules'),
  @JsonValue('overdue_commission')
  overdueCommission('overdue_commission'),
  @JsonValue('open_tickets')
  openTickets('open_tickets'),
  @JsonValue('documents_overdue')
  documentsOverdue('documents_overdue'),
  @JsonValue('showcase_review')
  showcaseReview('showcase_review'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const AttentionKey(this.json);

  factory AttentionKey.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError(
        'Cannot convert enum value with null JSON representation to String. '
        'This usually happens for \$unknown or @JsonValue(null) entries.',
      );
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<AttentionKey> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
