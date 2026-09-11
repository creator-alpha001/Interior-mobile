// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'ops_review_portfolio_item_body_decision.dart';

part 'ops_review_portfolio_item_body.freezed.dart';
part 'ops_review_portfolio_item_body.g.dart';

@Freezed()
abstract class OpsReviewPortfolioItemBody with _$OpsReviewPortfolioItemBody {
  const factory OpsReviewPortfolioItemBody({
    required OpsReviewPortfolioItemBodyDecision decision,
    String? note,
  }) = _OpsReviewPortfolioItemBody;

  factory OpsReviewPortfolioItemBody.fromJson(Map<String, Object?> json) =>
      _$OpsReviewPortfolioItemBodyFromJson(json);
}
