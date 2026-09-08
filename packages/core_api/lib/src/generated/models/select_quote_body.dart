// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'select_quote_body.freezed.dart';
part 'select_quote_body.g.dart';

@Freezed()
abstract class SelectQuoteBody with _$SelectQuoteBody {
  const factory SelectQuoteBody({required String quoteId}) = _SelectQuoteBody;

  factory SelectQuoteBody.fromJson(Map<String, Object?> json) =>
      _$SelectQuoteBodyFromJson(json);
}
