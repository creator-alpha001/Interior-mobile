// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'values.dart';

part 'options.freezed.dart';
part 'options.g.dart';

@Freezed()
abstract class Options with _$Options {
  const factory Options({
    required String id,
    required String name,
    required List<Values> values,
  }) = _Options;

  factory Options.fromJson(Map<String, Object?> json) =>
      _$OptionsFromJson(json);
}
