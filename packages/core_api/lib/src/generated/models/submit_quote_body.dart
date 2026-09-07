// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'quote_line_draft.dart';

part 'submit_quote_body.freezed.dart';
part 'submit_quote_body.g.dart';

@Freezed()
abstract class SubmitQuoteBody with _$SubmitQuoteBody {
  const factory SubmitQuoteBody({
    required List<QuoteLineDraft> lineItems,
    required num taxPercent,
    required int timelineDays,
    required int warrantyMonths,
    String? notes,
    @Default('')
    String warrantyDetails,
    @Default('')
    String materialsSummary,
  }) = _SubmitQuoteBody;
  
  factory SubmitQuoteBody.fromJson(Map<String, Object?> json) => _$SubmitQuoteBodyFromJson(json);
}
