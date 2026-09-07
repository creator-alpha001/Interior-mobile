// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'lead_sales_activity.dart';
import 'lead_view.dart';

part 'ops_lead_row.freezed.dart';
part 'ops_lead_row.g.dart';

@Freezed()
abstract class OpsLeadRow with _$OpsLeadRow {
  const factory OpsLeadRow({
    required LeadView lead,
    required String? agentName,
    required LeadSalesActivity? lastActivity,
    required String? followUpDate,
    required int unassignedDomains,
    required int awaitingReply,
    required int ageDays,
  }) = _OpsLeadRow;
  
  factory OpsLeadRow.fromJson(Map<String, Object?> json) => _$OpsLeadRowFromJson(json);
}
