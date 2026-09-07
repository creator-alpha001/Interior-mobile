// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'agreement.dart';
import 'agreement_line.dart';
import 'agreement_project.dart';
import 'commission_invoice.dart';
import 'masked_client_summary.dart';

part 'vendor_agreement_view.freezed.dart';
part 'vendor_agreement_view.g.dart';

@Freezed()
abstract class VendorAgreementView with _$VendorAgreementView {
  const factory VendorAgreementView({
    required Agreement agreement,
    required MaskedClientSummary client,
    required List<AgreementLine> lines,
    required bool isCombined,
    required List<AgreementProject> projects,
    required CommissionInvoice? invoice,
  }) = _VendorAgreementView;
  
  factory VendorAgreementView.fromJson(Map<String, Object?> json) => _$VendorAgreementViewFromJson(json);
}
