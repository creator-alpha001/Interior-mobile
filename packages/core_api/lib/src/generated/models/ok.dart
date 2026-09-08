// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ok.freezed.dart';
part 'ok.g.dart';

@Freezed()
abstract class Ok with _$Ok {
  const factory Ok({
    /// Always true.
    required bool ok,
  }) = _Ok;

  factory Ok.fromJson(Map<String, Object?> json) => _$OkFromJson(json);
}
