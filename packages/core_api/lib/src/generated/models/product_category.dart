// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_category.freezed.dart';
part 'product_category.g.dart';

@Freezed()
abstract class ProductCategory with _$ProductCategory {
  const factory ProductCategory({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String domainId,
    required String? parentId,
    required String name,
    required String slug,
    required String description,
    required String? imageUrl,
    required num sortOrder,
    required bool isActive,
  }) = _ProductCategory;
  
  factory ProductCategory.fromJson(Map<String, Object?> json) => _$ProductCategoryFromJson(json);
}
