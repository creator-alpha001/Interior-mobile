// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';
import 'product.dart';
import 'product_category.dart';

part 'product_view.freezed.dart';
part 'product_view.g.dart';

@Freezed()
abstract class ProductView with _$ProductView {
  const factory ProductView({
    required Product product,
    required Domain domain,
    required ProductCategory category,
    required int effectivePrice,
  }) = _ProductView;
  
  factory ProductView.fromJson(Map<String, Object?> json) => _$ProductViewFromJson(json);
}
