// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'google_sign_in_body.freezed.dart';
part 'google_sign_in_body.g.dart';

@Freezed()
abstract class GoogleSignInBody with _$GoogleSignInBody {
  const factory GoogleSignInBody({required String idToken}) = _GoogleSignInBody;

  factory GoogleSignInBody.fromJson(Map<String, Object?> json) =>
      _$GoogleSignInBodyFromJson(json);
}
