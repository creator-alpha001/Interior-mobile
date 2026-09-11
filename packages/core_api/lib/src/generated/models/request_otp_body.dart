// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'request_otp_body_channel.dart';

part 'request_otp_body.freezed.dart';
part 'request_otp_body.g.dart';

@Freezed()
abstract class RequestOtpBody with _$RequestOtpBody {
  const factory RequestOtpBody({
    required String mobile,
    RequestOtpBodyChannel? channel,
  }) = _RequestOtpBody;

  factory RequestOtpBody.fromJson(Map<String, Object?> json) =>
      _$RequestOtpBodyFromJson(json);
}
