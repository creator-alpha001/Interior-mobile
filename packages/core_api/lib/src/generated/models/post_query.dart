// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_query.freezed.dart';
part 'post_query.g.dart';

@Freezed()
abstract class PostQuery with _$PostQuery {
  const factory PostQuery({
    String? cursor,
    String? category,
    String? tag,
    String? domain,
    String? search,
    @Default(24)
    int limit,
  }) = _PostQuery;
  
  factory PostQuery.fromJson(Map<String, Object?> json) => _$PostQueryFromJson(json);
}
