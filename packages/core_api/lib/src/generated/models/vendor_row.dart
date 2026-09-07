// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'professional.dart';
import 'professional_domain_link.dart';
import 'professional_summary.dart';

part 'vendor_row.freezed.dart';
part 'vendor_row.g.dart';

@Freezed()
abstract class VendorRow with _$VendorRow {
  const factory VendorRow({
    required Professional professional,
    required ProfessionalSummary summary,
    required List<ProfessionalDomainLink> domainLinks,
    required List<String> serviceCities,
    required num liveJobs,
    required num pendingDomainRequests,
    required num totalRevenue,
    required num outstandingCommission,
    required bool hasSignedPartnerAgreement,
  }) = _VendorRow;
  
  factory VendorRow.fromJson(Map<String, Object?> json) => _$VendorRowFromJson(json);
}
