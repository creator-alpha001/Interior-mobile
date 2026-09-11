// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ops_update_partner_terms_body.freezed.dart';
part 'ops_update_partner_terms_body.g.dart';

@Freezed()
abstract class OpsUpdatePartnerTermsBody with _$OpsUpdatePartnerTermsBody {
  const factory OpsUpdatePartnerTermsBody({
    String? documentMediaId,
    String? hardcopyInstructions,
  }) = _OpsUpdatePartnerTermsBody;

  factory OpsUpdatePartnerTermsBody.fromJson(Map<String, Object?> json) =>
      _$OpsUpdatePartnerTermsBodyFromJson(json);
}
