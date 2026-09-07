// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'referral_entry.dart';

part 'referral_summary.freezed.dart';
part 'referral_summary.g.dart';

@Freezed()
abstract class ReferralSummary with _$ReferralSummary {
  const factory ReferralSummary({
    required String code,
    required String shareUrl,
    required num invited,
    required num earned,
    required num pending,
    required int rewardPerReferral,
    required List<ReferralEntry> referrals,
  }) = _ReferralSummary;
  
  factory ReferralSummary.fromJson(Map<String, Object?> json) => _$ReferralSummaryFromJson(json);
}
