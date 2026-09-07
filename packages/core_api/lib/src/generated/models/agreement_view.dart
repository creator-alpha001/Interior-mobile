// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'agreement.dart';
import 'agreement_line.dart';
import 'client_summary.dart';
import 'commission_invoice.dart';
import 'professional_summary.dart';
import 'project_view.dart';

part 'agreement_view.freezed.dart';
part 'agreement_view.g.dart';

@Freezed()
abstract class AgreementView with _$AgreementView {
  const factory AgreementView({
    required Agreement agreement,
    required ProfessionalSummary professional,
    required ClientSummary client,
    required List<AgreementLine> lines,
    required bool isCombined,
    required List<ProjectView> projects,
    required CommissionInvoice? invoice,
  }) = _AgreementView;
  
  factory AgreementView.fromJson(Map<String, Object?> json) => _$AgreementViewFromJson(json);
}
