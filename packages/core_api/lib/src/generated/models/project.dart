// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'project_milestone.dart';
import 'project_status.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@Freezed()
abstract class Project with _$Project {
  const factory Project({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String reference,
    required String leadDomainId,
    required String agreementId,
    required String clientId,
    required String professionalId,
    required String quoteId,
    required int value,
    required num commissionPercent,
    required int commissionAmount,
    required String? startDate,
    required String? estimatedEndDate,
    required String? actualEndDate,
    required num completionPercent,
    required ProjectStatus status,
    required List<ProjectMilestone> milestones,
  }) = _Project;

  factory Project.fromJson(Map<String, Object?> json) =>
      _$ProjectFromJson(json);
}
