// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_milestone_proof_body.freezed.dart';
part 'submit_milestone_proof_body.g.dart';

@Freezed()
abstract class SubmitMilestoneProofBody with _$SubmitMilestoneProofBody {
  const factory SubmitMilestoneProofBody({
    required String note,
    required List<String> proof,
  }) = _SubmitMilestoneProofBody;
  
  factory SubmitMilestoneProofBody.fromJson(Map<String, Object?> json) => _$SubmitMilestoneProofBodyFromJson(json);
}
