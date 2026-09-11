// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'ops_review_signed_copy_body_decision.dart';

part 'ops_review_signed_copy_body.freezed.dart';
part 'ops_review_signed_copy_body.g.dart';

@Freezed()
abstract class OpsReviewSignedCopyBody with _$OpsReviewSignedCopyBody {
  const factory OpsReviewSignedCopyBody({
    required OpsReviewSignedCopyBodyDecision decision,
    String? note,
  }) = _OpsReviewSignedCopyBody;

  factory OpsReviewSignedCopyBody.fromJson(Map<String, Object?> json) =>
      _$OpsReviewSignedCopyBodyFromJson(json);
}
