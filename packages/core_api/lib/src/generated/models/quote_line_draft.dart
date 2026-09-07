// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote_line_draft.freezed.dart';
part 'quote_line_draft.g.dart';

@Freezed()
abstract class QuoteLineDraft with _$QuoteLineDraft {
  const factory QuoteLineDraft({
    required String description,
    required num quantity,
    required String unit,
    required int rate,
  }) = _QuoteLineDraft;
  
  factory QuoteLineDraft.fromJson(Map<String, Object?> json) => _$QuoteLineDraftFromJson(json);
}
