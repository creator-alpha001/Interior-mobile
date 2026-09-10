// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'complete_google_sign_up_body.freezed.dart';
part 'complete_google_sign_up_body.g.dart';

@Freezed()
abstract class CompleteGoogleSignUpBody with _$CompleteGoogleSignUpBody {
  const factory CompleteGoogleSignUpBody({
    required String linkToken,
    String? name,
    String? cityId,
  }) = _CompleteGoogleSignUpBody;

  factory CompleteGoogleSignUpBody.fromJson(Map<String, Object?> json) =>
      _$CompleteGoogleSignUpBodyFromJson(json);
}
