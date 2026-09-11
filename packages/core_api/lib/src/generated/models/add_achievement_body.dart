// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'vendor_achievement_kind.dart';

part 'add_achievement_body.freezed.dart';
part 'add_achievement_body.g.dart';

@Freezed()
abstract class AddAchievementBody with _$AddAchievementBody {
  const factory AddAchievementBody({
    required VendorAchievementKind kind,
    required String title,
    int? year,
    @Default('') String issuer,
    @Default('') String description,
    @Default([]) List<String> media,
  }) = _AddAchievementBody;

  factory AddAchievementBody.fromJson(Map<String, Object?> json) =>
      _$AddAchievementBodyFromJson(json);
}
