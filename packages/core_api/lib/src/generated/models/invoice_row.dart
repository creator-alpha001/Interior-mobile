// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'commission_invoice.dart';
import 'professional_summary.dart';

part 'invoice_row.freezed.dart';
part 'invoice_row.g.dart';

@Freezed()
abstract class InvoiceRow with _$InvoiceRow {
  const factory InvoiceRow({
    required CommissionInvoice invoice,
    required ProfessionalSummary professional,
    required String agreementReference,
    required List<String> domains,
    required bool isCombined,
    required num daysOverdue,
  }) = _InvoiceRow;
  
  factory InvoiceRow.fromJson(Map<String, Object?> json) => _$InvoiceRowFromJson(json);
}
