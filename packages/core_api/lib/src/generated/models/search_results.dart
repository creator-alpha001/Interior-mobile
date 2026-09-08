// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'blog_post_view.dart';
import 'package_view.dart';
import 'product_view.dart';
import 'professional_summary.dart';

part 'search_results.freezed.dart';
part 'search_results.g.dart';

@Freezed()
abstract class SearchResults with _$SearchResults {
  const factory SearchResults({
    required String query,
    required int total,
    required List<ProductView> products,
    required List<PackageView> packages,
    required List<ProfessionalSummary> professionals,
    required List<BlogPostView> posts,
  }) = _SearchResults;

  factory SearchResults.fromJson(Map<String, Object?> json) =>
      _$SearchResultsFromJson(json);
}
