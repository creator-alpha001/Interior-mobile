// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain_rating.freezed.dart';
part 'domain_rating.g.dart';

@Freezed()
abstract class DomainRating with _$DomainRating {
  const factory DomainRating({
    required String domainId,
    required num avgRating,
    required int ratingCount,
  }) = _DomainRating;

  factory DomainRating.fromJson(Map<String, Object?> json) =>
      _$DomainRatingFromJson(json);
}
