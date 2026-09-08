// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'professional_service_area.freezed.dart';
part 'professional_service_area.g.dart';

@Freezed()
abstract class ProfessionalServiceArea with _$ProfessionalServiceArea {
  const factory ProfessionalServiceArea({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String professionalId,
    required String cityId,
    required List<String> localities,
  }) = _ProfessionalServiceArea;

  factory ProfessionalServiceArea.fromJson(Map<String, Object?> json) =>
      _$ProfessionalServiceAreaFromJson(json);
}
