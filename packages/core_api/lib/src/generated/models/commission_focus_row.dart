// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'commission_focus_row.freezed.dart';
part 'commission_focus_row.g.dart';

@Freezed()
abstract class CommissionFocusRow with _$CommissionFocusRow {
  const factory CommissionFocusRow({
    required String invoiceId,
    required String reference,
    required String professionalId,
    required String professionalName,
    required num amount,
    required String dueDate,
    required String status,
    required num daysOverdue,
    required List<String> domains,
  }) = _CommissionFocusRow;
  
  factory CommissionFocusRow.fromJson(Map<String, Object?> json) => _$CommissionFocusRowFromJson(json);
}
