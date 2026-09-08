// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ops_review_proof_body.freezed.dart';
part 'ops_review_proof_body.g.dart';

@Freezed()
abstract class OpsReviewProofBody with _$OpsReviewProofBody {
  const factory OpsReviewProofBody({required bool approve, String? note}) =
      _OpsReviewProofBody;

  factory OpsReviewProofBody.fromJson(Map<String, Object?> json) =>
      _$OpsReviewProofBodyFromJson(json);
}
