// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_asset.dart';

part 'service_package.freezed.dart';
part 'service_package.g.dart';

@Freezed()
abstract class ServicePackage with _$ServicePackage {
  const factory ServicePackage({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String domainId,
    required String name,
    required String slug,
    required String shortDescription,
    required String description,
    required List<MediaAsset> media,
    required int price,
    required String priceBasis,
    required num durationDays,
    required List<String> inclusions,
    required List<String> exclusions,
    required bool isFeatured,
    required bool isActive,
    required String? badge,
  }) = _ServicePackage;
  
  factory ServicePackage.fromJson(Map<String, Object?> json) => _$ServicePackageFromJson(json);
}
