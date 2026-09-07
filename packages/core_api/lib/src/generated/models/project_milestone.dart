// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_asset.dart';
import 'milestone_verification.dart';

part 'project_milestone.freezed.dart';
part 'project_milestone.g.dart';

@Freezed()
abstract class ProjectMilestone with _$ProjectMilestone {
  const factory ProjectMilestone({
    required String id,
    required String title,
    required String? description,
    required String? completedAt,
    required List<MediaAsset> proof,
    required String? proofNote,
    required String? submittedAt,
    required MilestoneVerification verification,
    required String? verifiedAt,
    required String? verifiedByUserId,
    required String? verifierNote,
  }) = _ProjectMilestone;
  
  factory ProjectMilestone.fromJson(Map<String, Object?> json) => _$ProjectMilestoneFromJson(json);
}
