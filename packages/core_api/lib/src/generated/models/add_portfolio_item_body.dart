// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_portfolio_item_body.freezed.dart';
part 'add_portfolio_item_body.g.dart';

@Freezed()
abstract class AddPortfolioItemBody with _$AddPortfolioItemBody {
  const factory AddPortfolioItemBody({
    required String domainId,
    required String title,
    required List<String> media,
    @Default('') String description,
    @Default([]) List<String> highlights,
    @Default('') String details,
    String? cityId,
  }) = _AddPortfolioItemBody;

  factory AddPortfolioItemBody.fromJson(Map<String, Object?> json) =>
      _$AddPortfolioItemBodyFromJson(json);
}
