// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain_approval_status.dart';
import 'media_asset.dart';
import 'vendor_achievement_kind.dart';

part 'vendor_achievement.freezed.dart';
part 'vendor_achievement.g.dart';

@Freezed()
abstract class VendorAchievement with _$VendorAchievement {
  const factory VendorAchievement({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String professionalId,
    required VendorAchievementKind kind,
    required String title,
    required String issuer,
    required int? year,
    required String description,
    required List<MediaAsset> media,
    required DomainApprovalStatus moderationStatus,
    required String? reviewNote,
    required String? reviewedAt,
  }) = _VendorAchievement;

  factory VendorAchievement.fromJson(Map<String, Object?> json) =>
      _$VendorAchievementFromJson(json);
}
