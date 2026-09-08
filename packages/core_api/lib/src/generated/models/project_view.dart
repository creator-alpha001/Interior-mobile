// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'client_summary.dart';
import 'domain.dart';
import 'professional_summary.dart';
import 'project.dart';
import 'review.dart';

part 'project_view.freezed.dart';
part 'project_view.g.dart';

@Freezed()
abstract class ProjectView with _$ProjectView {
  const factory ProjectView({
    required Project project,
    required Domain domain,
    required ProfessionalSummary professional,
    required ClientSummary client,
    required Review? review,
  }) = _ProjectView;

  factory ProjectView.fromJson(Map<String, Object?> json) =>
      _$ProjectViewFromJson(json);
}
