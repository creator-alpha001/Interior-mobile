// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';
import 'professional_summary.dart';
import 'quote.dart';

part 'quote_view.freezed.dart';
part 'quote_view.g.dart';

@Freezed()
abstract class QuoteView with _$QuoteView {
  const factory QuoteView({
    required Quote quote,
    required ProfessionalSummary professional,
    required Domain domain,
  }) = _QuoteView;

  factory QuoteView.fromJson(Map<String, Object?> json) =>
      _$QuoteViewFromJson(json);
}
