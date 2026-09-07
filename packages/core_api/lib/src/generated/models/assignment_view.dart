// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'lead_domain_assignment.dart';
import 'professional_summary.dart';

part 'assignment_view.freezed.dart';
part 'assignment_view.g.dart';

@Freezed()
abstract class AssignmentView with _$AssignmentView {
  const factory AssignmentView({
    required LeadDomainAssignment assignment,
    required ProfessionalSummary professional,
  }) = _AssignmentView;
  
  factory AssignmentView.fromJson(Map<String, Object?> json) => _$AssignmentViewFromJson(json);
}
