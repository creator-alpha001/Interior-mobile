// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'respond_to_lead_body_response.dart';

part 'respond_to_lead_body.freezed.dart';
part 'respond_to_lead_body.g.dart';

@Freezed()
abstract class RespondToLeadBody with _$RespondToLeadBody {
  const factory RespondToLeadBody({
    required RespondToLeadBodyResponse response,
    String? reason,
  }) = _RespondToLeadBody;

  factory RespondToLeadBody.fromJson(Map<String, Object?> json) =>
      _$RespondToLeadBodyFromJson(json);
}
