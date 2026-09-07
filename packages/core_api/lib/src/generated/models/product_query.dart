// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'product_query_sort.dart';

part 'product_query.freezed.dart';
part 'product_query.g.dart';

@Freezed()
abstract class ProductQuery with _$ProductQuery {
  const factory ProductQuery({
    String? cursor,
    String? domain,
    String? category,
    String? search,
    String? tags,
    String? city,
    int? maxPrice,
    @Default(24)
    int limit,
    @Default(ProductQuerySort.featured)
    ProductQuerySort sort,
  }) = _ProductQuery;
  
  factory ProductQuery.fromJson(Map<String, Object?> json) => _$ProductQueryFromJson(json);
}
