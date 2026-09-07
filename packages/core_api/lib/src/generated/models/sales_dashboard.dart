// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain_count.dart';
import 'urgency_count.dart';

part 'sales_dashboard.freezed.dart';
part 'sales_dashboard.g.dart';

@Freezed()
abstract class SalesDashboard with _$SalesDashboard {
  const factory SalesDashboard({
    required String agentName,
    required int target,
    required int newLeads,
    required int needsAssignment,
    required int awaitingReply,
    required int followUpsDue,
    required int visitsToday,
    required List<UrgencyCount> byUrgency,
    required List<DomainCount> byDomain,
  }) = _SalesDashboard;
  
  factory SalesDashboard.fromJson(Map<String, Object?> json) => _$SalesDashboardFromJson(json);
}
