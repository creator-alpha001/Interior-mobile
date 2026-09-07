// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'referral_reward_status.dart';

part 'referral.freezed.dart';
part 'referral.g.dart';

@Freezed()
abstract class Referral with _$Referral {
  const factory Referral({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String referrerUserId,
    required String referredUserId,
    required ReferralRewardStatus rewardStatus,
    required int rewardAmount,
  }) = _Referral;
  
  factory Referral.fromJson(Map<String, Object?> json) => _$ReferralFromJson(json);
}
