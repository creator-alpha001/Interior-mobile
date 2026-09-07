// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_token_param.freezed.dart';
part 'device_token_param.g.dart';

@Freezed()
abstract class DeviceTokenParam with _$DeviceTokenParam {
  const factory DeviceTokenParam({
    required String token,
  }) = _DeviceTokenParam;
  
  factory DeviceTokenParam.fromJson(Map<String, Object?> json) => _$DeviceTokenParamFromJson(json);
}
