// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'product_option_value.dart';

part 'product_option.freezed.dart';
part 'product_option.g.dart';

@Freezed()
abstract class ProductOption with _$ProductOption {
  const factory ProductOption({
    required String id,
    required String name,
    required List<ProductOptionValue> values,
  }) = _ProductOption;
  
  factory ProductOption.fromJson(Map<String, Object?> json) => _$ProductOptionFromJson(json);
}
