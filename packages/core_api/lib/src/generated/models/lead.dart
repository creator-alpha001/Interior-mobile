// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'lead_source.dart';
import 'lead_status.dart';
import 'media_asset.dart';
import 'site_accessibility_tag.dart';
import 'urgency.dart';

part 'lead.freezed.dart';
part 'lead.g.dart';

@Freezed()
abstract class Lead with _$Lead {
  const factory Lead({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String reference,
    required String clientId,
    required String cityId,
    required String description,
    required Urgency urgency,
    required int? budgetMin,
    required int? budgetMax,
    required List<SiteAccessibilityTag> siteAccessibilityTags,
    required List<MediaAsset> photos,
    required LeadSource source,
    required LeadStatus overallStatus,
    required String? assignedSalesAgentId,
  }) = _Lead;
  
  factory Lead.fromJson(Map<String, Object?> json) => _$LeadFromJson(json);
}
