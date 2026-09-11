// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'otp_challenge_channel.dart';

part 'otp_challenge.freezed.dart';
part 'otp_challenge.g.dart';

@Freezed()
abstract class OtpChallenge with _$OtpChallenge {
  const factory OtpChallenge({
    required String challengeId,
    required int expiresInSeconds,
    OtpChallengeChannel? channel,
    String? devCode,
  }) = _OtpChallenge;

  factory OtpChallenge.fromJson(Map<String, Object?> json) =>
      _$OtpChallengeFromJson(json);
}
