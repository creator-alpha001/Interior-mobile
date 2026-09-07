// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'commission_focus_row.dart';

part 'commission_summary.freezed.dart';
part 'commission_summary.g.dart';

@Freezed()
abstract class CommissionSummary with _$CommissionSummary {
  const factory CommissionSummary({
    required int pending,
    required int overdue,
    required num overdueCount,
    required num dueSoonCount,
    required List<CommissionFocusRow> rows,
  }) = _CommissionSummary;
  
  factory CommissionSummary.fromJson(Map<String, Object?> json) => _$CommissionSummaryFromJson(json);
}
