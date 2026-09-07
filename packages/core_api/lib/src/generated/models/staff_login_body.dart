// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_login_body.freezed.dart';
part 'staff_login_body.g.dart';

@Freezed()
abstract class StaffLoginBody with _$StaffLoginBody {
  const factory StaffLoginBody({
    required String email,
    required String password,
    String? totp,
  }) = _StaffLoginBody;
  
  factory StaffLoginBody.fromJson(Map<String, Object?> json) => _$StaffLoginBodyFromJson(json);
}
