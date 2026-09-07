// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'device_token_platform.dart';

part 'device_token.freezed.dart';
part 'device_token.g.dart';

@Freezed()
abstract class DeviceToken with _$DeviceToken {
  const factory DeviceToken({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String userId,
    required String token,
    required DeviceTokenPlatform platform,
  }) = _DeviceToken;
  
  factory DeviceToken.fromJson(Map<String, Object?> json) => _$DeviceTokenFromJson(json);
}
