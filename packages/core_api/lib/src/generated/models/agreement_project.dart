// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';
import 'project.dart';

part 'agreement_project.freezed.dart';
part 'agreement_project.g.dart';

@Freezed()
abstract class AgreementProject with _$AgreementProject {
  const factory AgreementProject({
    required Project project,
    required Domain domain,
  }) = _AgreementProject;
  
  factory AgreementProject.fromJson(Map<String, Object?> json) => _$AgreementProjectFromJson(json);
}
