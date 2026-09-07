// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user.freezed.dart';
part 'admin_user.g.dart';

@Freezed()
abstract class AdminUser with _$AdminUser {
  const factory AdminUser({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String userId,
    required String roleId,
  }) = _AdminUser;
  
  factory AdminUser.fromJson(Map<String, Object?> json) => _$AdminUserFromJson(json);
}
