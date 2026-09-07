// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'urgency.dart';

part 'urgency_count.freezed.dart';
part 'urgency_count.g.dart';

@Freezed()
abstract class UrgencyCount with _$UrgencyCount {
  const factory UrgencyCount({
    required Urgency urgency,
    required int count,
  }) = _UrgencyCount;
  
  factory UrgencyCount.fromJson(Map<String, Object?> json) => _$UrgencyCountFromJson(json);
}
