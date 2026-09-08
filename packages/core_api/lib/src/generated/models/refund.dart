// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'refund_status.dart';

part 'refund.freezed.dart';
part 'refund.g.dart';

@Freezed()
abstract class Refund with _$Refund {
  const factory Refund({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String projectId,
    required String clientId,
    required int amount,
    required String reason,
    required RefundStatus status,
    required String? processedAt,
    required String? handledByUserId,
  }) = _Refund;

  factory Refund.fromJson(Map<String, Object?> json) => _$RefundFromJson(json);
}
