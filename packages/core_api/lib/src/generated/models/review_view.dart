// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';
import 'review.dart';

part 'review_view.freezed.dart';
part 'review_view.g.dart';

@Freezed()
abstract class ReviewView with _$ReviewView {
  const factory ReviewView({
    required Review review,
    required String clientName,
    required Domain domain,
    required String projectTitle,
  }) = _ReviewView;

  factory ReviewView.fromJson(Map<String, Object?> json) =>
      _$ReviewViewFromJson(json);
}
