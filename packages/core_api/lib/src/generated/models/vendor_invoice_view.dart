// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'commission_invoice.dart';

part 'vendor_invoice_view.freezed.dart';
part 'vendor_invoice_view.g.dart';

@Freezed()
abstract class VendorInvoiceView with _$VendorInvoiceView {
  const factory VendorInvoiceView({
    required CommissionInvoice invoice,
    required String agreementReference,
    required List<String> domains,
  }) = _VendorInvoiceView;

  factory VendorInvoiceView.fromJson(Map<String, Object?> json) =>
      _$VendorInvoiceViewFromJson(json);
}
