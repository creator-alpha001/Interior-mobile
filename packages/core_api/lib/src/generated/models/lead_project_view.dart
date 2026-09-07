// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'project_milestone.dart';

part 'lead_project_view.freezed.dart';
part 'lead_project_view.g.dart';

@Freezed()
abstract class LeadProjectView with _$LeadProjectView {
  const factory LeadProjectView({
    required String projectId,
    required String reference,
    required String leadDomainId,
    required String domainName,
    required String professionalName,
    required String professionalId,
    required String status,
    required num completionPercent,
    required int approvedStages,
    required int totalStages,
    required int awaitingReview,
    required String? currentStage,
    required List<ProjectMilestone> milestones,
  }) = _LeadProjectView;
  
  factory LeadProjectView.fromJson(Map<String, Object?> json) => _$LeadProjectViewFromJson(json);
}
