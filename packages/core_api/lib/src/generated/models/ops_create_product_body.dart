// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'options.dart';
import 'price_unit.dart';

part 'ops_create_product_body.freezed.dart';
part 'ops_create_product_body.g.dart';

@Freezed()
abstract class OpsCreateProductBody with _$OpsCreateProductBody {
  const factory OpsCreateProductBody({
    required String domainId,
    required String categoryId,
    required String name,
    required int basePrice,
    required PriceUnit priceUnit,
    required Map<String, String> specs,
    @Default('') String shortDescription,
    @Default('') String description,
    @Default(0) int leadTimeDays,
    @Default(true) bool isCustomisable,
    @Default([]) List<Options> options,
    @Default([]) List<String> tags,
    @Default(false) bool isFeatured,
    @Default([]) List<String> mediaIds,
  }) = _OpsCreateProductBody;

  factory OpsCreateProductBody.fromJson(Map<String, Object?> json) =>
      _$OpsCreateProductBodyFromJson(json);
}
