// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_item.freezed.dart';
part 'saved_item.g.dart';

@Freezed()
abstract class SavedItem with _$SavedItem {
  const factory SavedItem({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String clientId,
    required String? productId,
    required String? packageId,
  }) = _SavedItem;
  
  factory SavedItem.fromJson(Map<String, Object?> json) => _$SavedItemFromJson(json);
}
