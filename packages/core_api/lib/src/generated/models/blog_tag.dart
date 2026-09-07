// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'blog_tag.freezed.dart';
part 'blog_tag.g.dart';

@Freezed()
abstract class BlogTag with _$BlogTag {
  const factory BlogTag({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String name,
    required String slug,
  }) = _BlogTag;
  
  factory BlogTag.fromJson(Map<String, Object?> json) => _$BlogTagFromJson(json);
}
