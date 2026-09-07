// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_asset_type.dart';

part 'media_asset.freezed.dart';
part 'media_asset.g.dart';

@Freezed()
abstract class MediaAsset with _$MediaAsset {
  const factory MediaAsset({
    required String id,
    required String url,
    required MediaAssetType type,
    String? caption,
  }) = _MediaAsset;
  
  factory MediaAsset.fromJson(Map<String, Object?> json) => _$MediaAssetFromJson(json);
}
