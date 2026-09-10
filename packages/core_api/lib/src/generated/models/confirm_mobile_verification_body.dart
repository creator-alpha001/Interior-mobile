// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_mobile_verification_body.freezed.dart';
part 'confirm_mobile_verification_body.g.dart';

@Freezed()
abstract class ConfirmMobileVerificationBody
    with _$ConfirmMobileVerificationBody {
  const factory ConfirmMobileVerificationBody({
    required String challengeId,
    required String code,
  }) = _ConfirmMobileVerificationBody;

  factory ConfirmMobileVerificationBody.fromJson(Map<String, Object?> json) =>
      _$ConfirmMobileVerificationBodyFromJson(json);
}
