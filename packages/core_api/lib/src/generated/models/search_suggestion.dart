// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_suggestion.freezed.dart';
part 'search_suggestion.g.dart';

@Freezed()
abstract class SearchSuggestion with _$SearchSuggestion {
  const factory SearchSuggestion({
    required String label,
    required String hint,
    required String href,
  }) = _SearchSuggestion;

  factory SearchSuggestion.fromJson(Map<String, Object?> json) =>
      _$SearchSuggestionFromJson(json);
}
