// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_signed_copy_body.freezed.dart';
part 'submit_signed_copy_body.g.dart';

@Freezed()
abstract class SubmitSignedCopyBody with _$SubmitSignedCopyBody {
  const factory SubmitSignedCopyBody({
    required List<String> files,
    String? stampCertificateNumber,
  }) = _SubmitSignedCopyBody;

  factory SubmitSignedCopyBody.fromJson(Map<String, Object?> json) =>
      _$SubmitSignedCopyBodyFromJson(json);
}
