// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'register_device_body_platform.dart';

part 'register_device_body.freezed.dart';
part 'register_device_body.g.dart';

@Freezed()
abstract class RegisterDeviceBody with _$RegisterDeviceBody {
  const factory RegisterDeviceBody({
    required String token,
    required RegisterDeviceBodyPlatform platform,
    String? appVersion,
  }) = _RegisterDeviceBody;

  factory RegisterDeviceBody.fromJson(Map<String, Object?> json) =>
      _$RegisterDeviceBodyFromJson(json);
}
