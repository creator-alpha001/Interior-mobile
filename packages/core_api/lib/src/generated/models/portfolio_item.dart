// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain_approval_status.dart';
import 'media_asset.dart';

part 'portfolio_item.freezed.dart';
part 'portfolio_item.g.dart';

@Freezed()
abstract class PortfolioItem with _$PortfolioItem {
  const factory PortfolioItem({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String professionalId,
    required String domainId,
    required String title,
    required String description,
    required List<String> highlights,
    required String details,
    required List<MediaAsset> media,
    required DomainApprovalStatus moderationStatus,
    required String? cityId,
    required String? reviewNote,
    required String? reviewedAt,
  }) = _PortfolioItem;

  factory PortfolioItem.fromJson(Map<String, Object?> json) =>
      _$PortfolioItemFromJson(json);
}
