// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_agent.freezed.dart';
part 'sales_agent.g.dart';

@Freezed()
abstract class SalesAgent with _$SalesAgent {
  const factory SalesAgent({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String userId,
    required List<String> assignedCityIds,
    required num dailyTarget,
  }) = _SalesAgent;
  
  factory SalesAgent.fromJson(Map<String, Object?> json) => _$SalesAgentFromJson(json);
}
