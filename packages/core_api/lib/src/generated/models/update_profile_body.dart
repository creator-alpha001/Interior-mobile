// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_profile_body.freezed.dart';
part 'update_profile_body.g.dart';

@Freezed()
abstract class UpdateProfileBody with _$UpdateProfileBody {
  const factory UpdateProfileBody({String? name, String? cityId}) =
      _UpdateProfileBody;

  factory UpdateProfileBody.fromJson(Map<String, Object?> json) =>
      _$UpdateProfileBodyFromJson(json);
}
