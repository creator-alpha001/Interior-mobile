// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote_line_item.freezed.dart';
part 'quote_line_item.g.dart';

@Freezed()
abstract class QuoteLineItem with _$QuoteLineItem {
  const factory QuoteLineItem({
    required String id,
    required String description,
    required num quantity,
    required String unit,
    required int rate,
    required int amount,
  }) = _QuoteLineItem;
  
  factory QuoteLineItem.fromJson(Map<String, Object?> json) => _$QuoteLineItemFromJson(json);
}
