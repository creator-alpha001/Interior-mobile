// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'invoice_status.dart';

part 'commission_invoice.freezed.dart';
part 'commission_invoice.g.dart';

@Freezed()
abstract class CommissionInvoice with _$CommissionInvoice {
  const factory CommissionInvoice({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String reference,
    required String professionalId,
    required String agreementId,
    required int amount,
    required InvoiceStatus status,
    required String dueDate,
    required String? paidDate,
    required String? adjustmentNote,
  }) = _CommissionInvoice;

  factory CommissionInvoice.fromJson(Map<String, Object?> json) =>
      _$CommissionInvoiceFromJson(json);
}
