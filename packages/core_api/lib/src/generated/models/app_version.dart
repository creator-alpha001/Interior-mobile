// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_version.freezed.dart';
part 'app_version.g.dart';

@Freezed()
abstract class AppVersion with _$AppVersion {
  const factory AppVersion({
    required num minBuild,
    required String message,
  }) = _AppVersion;
  
  factory AppVersion.fromJson(Map<String, Object?> json) => _$AppVersionFromJson(json);
}
