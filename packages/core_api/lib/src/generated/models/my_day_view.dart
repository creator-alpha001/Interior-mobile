// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'commission_summary.dart';
import 'ops_lead_row.dart';

part 'my_day_view.freezed.dart';
part 'my_day_view.g.dart';

@Freezed()
abstract class MyDayView with _$MyDayView {
  const factory MyDayView({
    required String agentName,
    required int target,
    required List<OpsLeadRow> live,
    required List<OpsLeadRow> awaitingReply,
    required List<OpsLeadRow> needsAssignment,
    required List<OpsLeadRow> followUpsDue,
    required List<OpsLeadRow> neverCalled,
    required List<OpsLeadRow> stalled,
    required int visitsToday,
    required int visitsNeedingOutcome,
    required CommissionSummary commission,
  }) = _MyDayView;

  factory MyDayView.fromJson(Map<String, Object?> json) =>
      _$MyDayViewFromJson(json);
}
