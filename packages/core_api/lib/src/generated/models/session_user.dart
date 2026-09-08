// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'actor.dart';

part 'session_user.freezed.dart';
part 'session_user.g.dart';

@Freezed()
abstract class SessionUser with _$SessionUser {
  const factory SessionUser({
    required Actor actor,
    required String name,
    required String mobile,
    required String? avatarUrl,
  }) = _SessionUser;

  factory SessionUser.fromJson(Map<String, Object?> json) =>
      _$SessionUserFromJson(json);
}
