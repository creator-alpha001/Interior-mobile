// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'hardcopy_method.dart';

part 'report_hardcopy_body.freezed.dart';
part 'report_hardcopy_body.g.dart';

@Freezed()
abstract class ReportHardcopyBody with _$ReportHardcopyBody {
  const factory ReportHardcopyBody({
    required HardcopyMethod method,
    String? courier,
    String? trackingNumber,
    String? note,
  }) = _ReportHardcopyBody;

  factory ReportHardcopyBody.fromJson(Map<String, Object?> json) =>
      _$ReportHardcopyBodyFromJson(json);
}
