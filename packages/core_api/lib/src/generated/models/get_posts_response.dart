// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'blog_post_view.dart';

part 'get_posts_response.freezed.dart';
part 'get_posts_response.g.dart';

@Freezed()
abstract class GetPostsResponse with _$GetPostsResponse {
  const factory GetPostsResponse({
    required List<BlogPostView> items,
    required String? nextCursor,
    required int total,
  }) = _GetPostsResponse;
  
  factory GetPostsResponse.fromJson(Map<String, Object?> json) => _$GetPostsResponseFromJson(json);
}
