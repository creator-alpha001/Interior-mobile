// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_review_body.freezed.dart';
part 'submit_review_body.g.dart';

@Freezed()
abstract class SubmitReviewBody with _$SubmitReviewBody {
  const factory SubmitReviewBody({
    required String projectId,
    required int rating,
    int? qualityRating,
    int? timelinessRating,
    int? professionalismRating,
    @Default('')
    String comment,
  }) = _SubmitReviewBody;
  
  factory SubmitReviewBody.fromJson(Map<String, Object?> json) => _$SubmitReviewBodyFromJson(json);
}
