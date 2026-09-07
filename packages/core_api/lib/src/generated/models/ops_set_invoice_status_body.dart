// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'invoice_status.dart';

part 'ops_set_invoice_status_body.freezed.dart';
part 'ops_set_invoice_status_body.g.dart';

@Freezed()
abstract class OpsSetInvoiceStatusBody with _$OpsSetInvoiceStatusBody {
  const factory OpsSetInvoiceStatusBody({
    required InvoiceStatus status,
    String? note,
  }) = _OpsSetInvoiceStatusBody;
  
  factory OpsSetInvoiceStatusBody.fromJson(Map<String, Object?> json) => _$OpsSetInvoiceStatusBodyFromJson(json);
}
