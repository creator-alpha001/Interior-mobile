// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'values2.freezed.dart';
part 'values2.g.dart';

@Freezed()
abstract class Values2 with _$Values2 {
  const factory Values2({
    required String id,
    required String label,
    required int priceDelta,
  }) = _Values2;

  factory Values2.fromJson(Map<String, Object?> json) =>
      _$Values2FromJson(json);
}
