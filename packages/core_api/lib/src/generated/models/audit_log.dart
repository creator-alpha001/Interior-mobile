// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log.freezed.dart';
part 'audit_log.g.dart';

@Freezed()
abstract class AuditLog with _$AuditLog {
  const factory AuditLog({
    required String id,
    required String actorUserId,
    required String action,
    required String entityType,
    required String entityId,
    required String summary,
    required String createdAt,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, Object?> json) =>
      _$AuditLogFromJson(json);
}
