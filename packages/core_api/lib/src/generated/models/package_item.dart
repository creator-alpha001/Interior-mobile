// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_item.freezed.dart';
part 'package_item.g.dart';

@Freezed()
abstract class PackageItem with _$PackageItem {
  const factory PackageItem({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String packageId,
    required String? productId,
    required String label,
    required num quantity,
  }) = _PackageItem;
  
  factory PackageItem.fromJson(Map<String, Object?> json) => _$PackageItemFromJson(json);
}
