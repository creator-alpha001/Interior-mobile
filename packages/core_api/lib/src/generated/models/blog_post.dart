// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'blog_post_status.dart';

part 'blog_post.freezed.dart';
part 'blog_post.g.dart';

@Freezed()
abstract class BlogPost with _$BlogPost {
  const factory BlogPost({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String title,
    required String slug,
    required String excerpt,
    required String body,
    required String coverImageUrl,
    required String authorName,
    required String authorRole,
    required String categoryId,
    required List<String> tagIds,
    required String? domainId,
    required BlogPostStatus status,
    required String? publishedAt,
    required int readingMinutes,
    required String seoTitle,
    required String seoDescription,
    required String? ogImageUrl,
    required bool isFeatured,
  }) = _BlogPost;

  factory BlogPost.fromJson(Map<String, Object?> json) =>
      _$BlogPostFromJson(json);
}
