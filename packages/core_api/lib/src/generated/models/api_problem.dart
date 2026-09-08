// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_problem.freezed.dart';
part 'api_problem.g.dart';

/// Every failure carries this shape. `code` is stable and machine-readable; `message` is written for a person.
@Freezed()
abstract class ApiProblem with _$ApiProblem {
  const factory ApiProblem({
    required String code,
    required String message,
    dynamic details,
  }) = _ApiProblem;

  factory ApiProblem.fromJson(Map<String, Object?> json) =>
      _$ApiProblemFromJson(json);
}
