// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain_labels.dart';

part 'domain.freezed.dart';
part 'domain.g.dart';

@Freezed()
abstract class Domain with _$Domain {
  const factory Domain({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String name,
    required String slug,
    required String tagline,
    required String description,
    required String iconKey,
    required String? bannerUrl,
    required num defaultCommissionPercent,
    required bool isActive,
    required num sortOrder,
    required DomainLabels labels,
  }) = _Domain;
  
  factory Domain.fromJson(Map<String, Object?> json) => _$DomainFromJson(json);
}
