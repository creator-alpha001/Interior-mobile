// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'notification_entity_type.dart';
import 'notification_type.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@Freezed()
abstract class Notification with _$Notification {
  const factory Notification({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    required NotificationEntityType? entityType,
    required String? entityId,
    required bool isRead,
  }) = _Notification;

  factory Notification.fromJson(Map<String, Object?> json) =>
      _$NotificationFromJson(json);
}
