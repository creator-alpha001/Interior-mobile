// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'values2.dart';

part 'options2.freezed.dart';
part 'options2.g.dart';

@Freezed()
abstract class Options2 with _$Options2 {
  const factory Options2({
    required String id,
    required String name,
    required List<Values2> values,
  }) = _Options2;

  factory Options2.fromJson(Map<String, Object?> json) =>
      _$Options2FromJson(json);
}
