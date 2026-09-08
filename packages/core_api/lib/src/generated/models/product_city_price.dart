// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_city_price.freezed.dart';
part 'product_city_price.g.dart';

@Freezed()
abstract class ProductCityPrice with _$ProductCityPrice {
  const factory ProductCityPrice({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String productId,
    required String cityId,
    required int price,
  }) = _ProductCityPrice;

  factory ProductCityPrice.fromJson(Map<String, Object?> json) =>
      _$ProductCityPriceFromJson(json);
}
