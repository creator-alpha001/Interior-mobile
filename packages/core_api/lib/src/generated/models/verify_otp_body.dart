// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_otp_body.freezed.dart';
part 'verify_otp_body.g.dart';

@Freezed()
abstract class VerifyOtpBody with _$VerifyOtpBody {
  const factory VerifyOtpBody({
    required String challengeId,
    required String code,
    String? name,
    String? cityId,
    String? linkToken,
  }) = _VerifyOtpBody;

  factory VerifyOtpBody.fromJson(Map<String, Object?> json) =>
      _$VerifyOtpBodyFromJson(json);
}
