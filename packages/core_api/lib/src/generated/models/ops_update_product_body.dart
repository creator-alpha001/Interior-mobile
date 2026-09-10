// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'options2.dart';
import 'price_unit.dart';

part 'ops_update_product_body.freezed.dart';
part 'ops_update_product_body.g.dart';

@Freezed()
abstract class OpsUpdateProductBody with _$OpsUpdateProductBody {
  const factory OpsUpdateProductBody({
    required Map<String, String> specs,
    @Default('') String shortDescription,
    @Default('') String description,
    @Default(0) int leadTimeDays,
    @Default(true) bool isCustomisable,
    @Default([]) List<Options2> options,
    @Default([]) List<String> tags,
    @Default(false) bool isFeatured,
    @Default([]) List<String> mediaIds,
    String? domainId,
    String? categoryId,
    String? name,
    int? basePrice,
    PriceUnit? priceUnit,
    bool? isActive,
  }) = _OpsUpdateProductBody;

  factory OpsUpdateProductBody.fromJson(Map<String, Object?> json) =>
      _$OpsUpdateProductBodyFromJson(json);
}
