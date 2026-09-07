// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'professional_summary.dart';

part 'get_professionals_response.freezed.dart';
part 'get_professionals_response.g.dart';

@Freezed()
abstract class GetProfessionalsResponse with _$GetProfessionalsResponse {
  const factory GetProfessionalsResponse({
    required List<ProfessionalSummary> items,
    required String? nextCursor,
    required int total,
  }) = _GetProfessionalsResponse;
  
  factory GetProfessionalsResponse.fromJson(Map<String, Object?> json) => _$GetProfessionalsResponseFromJson(json);
}
