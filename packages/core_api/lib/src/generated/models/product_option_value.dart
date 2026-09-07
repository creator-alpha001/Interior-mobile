// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_option_value.freezed.dart';
part 'product_option_value.g.dart';

@Freezed()
abstract class ProductOptionValue with _$ProductOptionValue {
  const factory ProductOptionValue({
    required String id,
    required String label,
    required num priceDelta,
  }) = _ProductOptionValue;
  
  factory ProductOptionValue.fromJson(Map<String, Object?> json) => _$ProductOptionValueFromJson(json);
}
