// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

@Freezed()
abstract class Review with _$Review {
  const factory Review({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String projectId,
    required String clientId,
    required String professionalId,
    required String domainId,
    required dynamic rating,
    required String comment,
    required num? qualityRating,
    required num? timelinessRating,
    required num? professionalismRating,
  }) = _Review;
  
  factory Review.fromJson(Map<String, Object?> json) => _$ReviewFromJson(json);
}
