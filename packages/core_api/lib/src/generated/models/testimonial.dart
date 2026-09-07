// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'testimonial.freezed.dart';
part 'testimonial.g.dart';

@Freezed()
abstract class Testimonial with _$Testimonial {
  const factory Testimonial({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String clientName,
    required String cityName,
    required String domainId,
    required num rating,
    required String quote,
    required String? avatarUrl,
  }) = _Testimonial;
  
  factory Testimonial.fromJson(Map<String, Object?> json) => _$TestimonialFromJson(json);
}
