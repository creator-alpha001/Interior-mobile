// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'blog_category.dart';
import 'blog_post.dart';
import 'domain.dart';

part 'blog_post_view.freezed.dart';
part 'blog_post_view.g.dart';

@Freezed()
abstract class BlogPostView with _$BlogPostView {
  const factory BlogPostView({
    required BlogPost post,
    required BlogCategory category,
    required List<String> tags,
    required Domain? domain,
  }) = _BlogPostView;

  factory BlogPostView.fromJson(Map<String, Object?> json) =>
      _$BlogPostViewFromJson(json);
}
