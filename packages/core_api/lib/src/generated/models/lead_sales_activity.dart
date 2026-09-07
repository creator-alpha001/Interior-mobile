// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'lead_sales_activity_call_status.dart';

part 'lead_sales_activity.freezed.dart';
part 'lead_sales_activity.g.dart';

@Freezed()
abstract class LeadSalesActivity with _$LeadSalesActivity {
  const factory LeadSalesActivity({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String leadId,
    required String salesAgentId,
    required LeadSalesActivityCallStatus callStatus,
    required String remarks,
    required String? recordingUrl,
    required String? followUpDate,
  }) = _LeadSalesActivity;
  
  factory LeadSalesActivity.fromJson(Map<String, Object?> json) => _$LeadSalesActivityFromJson(json);
}
