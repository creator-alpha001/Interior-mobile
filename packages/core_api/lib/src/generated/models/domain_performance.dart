// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';

part 'domain_performance.freezed.dart';
part 'domain_performance.g.dart';

@Freezed()
abstract class DomainPerformance with _$DomainPerformance {
  const factory DomainPerformance({
    required Domain domain,
    required num rating,
    required int ratingCount,
    required int completed,
    required int won,
    required int lost,
    required num winRatePercent,
    required num commissionPercent,
  }) = _DomainPerformance;

  factory DomainPerformance.fromJson(Map<String, Object?> json) =>
      _$DomainPerformanceFromJson(json);
}
