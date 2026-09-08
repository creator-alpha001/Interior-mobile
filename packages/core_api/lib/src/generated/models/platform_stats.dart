// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_stats.freezed.dart';
part 'platform_stats.g.dart';

@Freezed()
abstract class PlatformStats with _$PlatformStats {
  const factory PlatformStats({
    required int professionals,
    required int projects,
    required int cities,
    required num avgRating,
  }) = _PlatformStats;

  factory PlatformStats.fromJson(Map<String, Object?> json) =>
      _$PlatformStatsFromJson(json);
}
