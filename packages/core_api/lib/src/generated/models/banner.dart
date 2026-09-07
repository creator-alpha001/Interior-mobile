// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner.freezed.dart';
part 'banner.g.dart';

@Freezed()
abstract class Banner with _$Banner {
  const factory Banner({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String title,
    required String subtitle,
    required String imageUrl,
    required String ctaLabel,
    required String ctaHref,
    required String? domainId,
    required List<String> cityIds,
    required bool isActive,
    required num sortOrder,
  }) = _Banner;
  
  factory Banner.fromJson(Map<String, Object?> json) => _$BannerFromJson(json);
}
