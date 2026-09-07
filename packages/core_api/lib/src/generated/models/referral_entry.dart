// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'referral.dart';

part 'referral_entry.freezed.dart';
part 'referral_entry.g.dart';

@Freezed()
abstract class ReferralEntry with _$ReferralEntry {
  const factory ReferralEntry({
    required Referral referral,
    required String name,
  }) = _ReferralEntry;
  
  factory ReferralEntry.fromJson(Map<String, Object?> json) => _$ReferralEntryFromJson(json);
}
