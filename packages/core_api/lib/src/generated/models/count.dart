// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'count.freezed.dart';
part 'count.g.dart';

@Freezed()
abstract class Count with _$Count {
  const factory Count({required int count}) = _Count;

  factory Count.fromJson(Map<String, Object?> json) => _$CountFromJson(json);
}
