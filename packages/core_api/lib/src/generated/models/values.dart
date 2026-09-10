// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'values.freezed.dart';
part 'values.g.dart';

@Freezed()
abstract class Values with _$Values {
  const factory Values({
    required String id,
    required String label,
    required int priceDelta,
  }) = _Values;

  factory Values.fromJson(Map<String, Object?> json) => _$ValuesFromJson(json);
}
