// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'quote_line_item.dart';
import 'quote_status.dart';

part 'quote.freezed.dart';
part 'quote.g.dart';

@Freezed()
abstract class Quote with _$Quote {
  const factory Quote({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String leadDomainId,
    required String professionalId,
    required int version,
    required String? supersedesQuoteId,
    required List<QuoteLineItem> lineItems,
    required int subtotal,
    required num taxPercent,
    required int taxAmount,
    required int total,
    required int timelineDays,
    required int warrantyMonths,
    required String warrantyDetails,
    required String materialsSummary,
    required String? boqUrl,
    required String? quotePdfUrl,
    required QuoteStatus status,
    required String? notes,
  }) = _Quote;

  factory Quote.fromJson(Map<String, Object?> json) => _$QuoteFromJson(json);
}
