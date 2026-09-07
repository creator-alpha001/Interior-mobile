// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_password.freezed.dart';
part 'set_password.g.dart';

@Freezed()
abstract class SetPassword with _$SetPassword {
  const factory SetPassword({
    required String password,
  }) = _SetPassword;
  
  factory SetPassword.fromJson(Map<String, Object?> json) => _$SetPasswordFromJson(json);
}
