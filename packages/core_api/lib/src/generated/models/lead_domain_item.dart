// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead_domain_item.freezed.dart';
part 'lead_domain_item.g.dart';

@Freezed()
abstract class LeadDomainItem with _$LeadDomainItem {
  const factory LeadDomainItem({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String leadDomainId,
    required String? productId,
    required String? packageId,
    required String itemName,
    required num quantity,
    required Map<String, String> selectedOptions,
    required int? indicativePrice,
    required String? customerNotes,
  }) = _LeadDomainItem;

  factory LeadDomainItem.fromJson(Map<String, Object?> json) =>
      _$LeadDomainItemFromJson(json);
}
