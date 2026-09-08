// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'lead_queue_status.dart';
import 'urgency.dart';

part 'lead_queue.freezed.dart';
part 'lead_queue.g.dart';

@Freezed()
abstract class LeadQueue with _$LeadQueue {
  const factory LeadQueue({
    String? cursor,
    LeadQueueStatus? status,
    String? domain,
    String? city,
    Urgency? urgency,
    String? agentId,
    String? search,
    dynamic needsAssignment,
    @Default(24) int limit,
  }) = _LeadQueue;

  factory LeadQueue.fromJson(Map<String, Object?> json) =>
      _$LeadQueueFromJson(json);
}
