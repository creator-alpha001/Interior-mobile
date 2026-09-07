// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_role.dart';
import 'user_status.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@Freezed()
abstract class User with _$User {
  const factory User({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String name,
    required String mobile,
    required String? email,
    required UserRole role,
    required String cityId,
    required UserStatus status,
    required String? avatarUrl,
  }) = _User;
  
  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
