// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'product_view.dart';

part 'get_products_response.freezed.dart';
part 'get_products_response.g.dart';

@Freezed()
abstract class GetProductsResponse with _$GetProductsResponse {
  const factory GetProductsResponse({
    required List<ProductView> items,
    required String? nextCursor,
    required int total,
  }) = _GetProductsResponse;
  
  factory GetProductsResponse.fromJson(Map<String, Object?> json) => _$GetProductsResponseFromJson(json);
}
