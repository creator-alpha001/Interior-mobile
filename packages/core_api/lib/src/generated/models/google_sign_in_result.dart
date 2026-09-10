// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_session.dart';
import 'google_sign_in_result_status.dart';

part 'google_sign_in_result.freezed.dart';
part 'google_sign_in_result.g.dart';

@Freezed()
abstract class GoogleSignInResult with _$GoogleSignInResult {
  const factory GoogleSignInResult({
    required GoogleSignInResultStatus status,
    AuthSession? session,
    String? linkToken,
    String? email,
    String? name,
  }) = _GoogleSignInResult;

  factory GoogleSignInResult.fromJson(Map<String, Object?> json) =>
      _$GoogleSignInResultFromJson(json);
}
