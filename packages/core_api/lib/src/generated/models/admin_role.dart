// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'permission_key.dart';

part 'admin_role.freezed.dart';
part 'admin_role.g.dart';

@Freezed()
abstract class AdminRole with _$AdminRole {
  const factory AdminRole({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String name,
    required String description,
    required List<PermissionKey> permissions,
  }) = _AdminRole;

  factory AdminRole.fromJson(Map<String, Object?> json) =>
      _$AdminRoleFromJson(json);
}
