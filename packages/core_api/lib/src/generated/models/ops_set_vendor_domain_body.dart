// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain_approval_status.dart';

part 'ops_set_vendor_domain_body.freezed.dart';
part 'ops_set_vendor_domain_body.g.dart';

@Freezed()
abstract class OpsSetVendorDomainBody with _$OpsSetVendorDomainBody {
  const factory OpsSetVendorDomainBody({
    DomainApprovalStatus? status,
    int? commissionPercentOverride,
  }) = _OpsSetVendorDomainBody;

  factory OpsSetVendorDomainBody.fromJson(Map<String, Object?> json) =>
      _$OpsSetVendorDomainBodyFromJson(json);
}
