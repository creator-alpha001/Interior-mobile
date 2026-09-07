// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_asset.dart';
import 'price_unit.dart';
import 'product_option.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@Freezed()
abstract class Product with _$Product {
  const factory Product({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String domainId,
    required String categoryId,
    required String name,
    required String slug,
    required String shortDescription,
    required String description,
    required List<MediaAsset> media,
    required num basePrice,
    required PriceUnit priceUnit,
    required num leadTimeDays,
    required bool isCustomisable,
    required Map<String, String> specs,
    required List<ProductOption> options,
    required List<String> tags,
    required bool isFeatured,
    required bool isActive,
    required num rating,
    required num ratingCount,
  }) = _Product;
  
  factory Product.fromJson(Map<String, Object?> json) => _$ProductFromJson(json);
}
