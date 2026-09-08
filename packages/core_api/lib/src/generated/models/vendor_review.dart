// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';
import 'review.dart';

part 'vendor_review.freezed.dart';
part 'vendor_review.g.dart';

@Freezed()
abstract class VendorReview with _$VendorReview {
  const factory VendorReview({
    required Review review,
    required Domain domain,
    required String clientName,
  }) = _VendorReview;

  factory VendorReview.fromJson(Map<String, Object?> json) =>
      _$VendorReviewFromJson(json);
}
