// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'blog_category.freezed.dart';
part 'blog_category.g.dart';

@Freezed()
abstract class BlogCategory with _$BlogCategory {
  const factory BlogCategory({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String name,
    required String slug,
    required String description,
  }) = _BlogCategory;
  
  factory BlogCategory.fromJson(Map<String, Object?> json) => _$BlogCategoryFromJson(json);
}
