// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'verification_status.dart';

part 'ops_set_vendor_status_body.freezed.dart';
part 'ops_set_vendor_status_body.g.dart';

@Freezed()
abstract class OpsSetVendorStatusBody with _$OpsSetVendorStatusBody {
  const factory OpsSetVendorStatusBody({required VerificationStatus status}) =
      _OpsSetVendorStatusBody;

  factory OpsSetVendorStatusBody.fromJson(Map<String, Object?> json) =>
      _$OpsSetVendorStatusBodyFromJson(json);
}
