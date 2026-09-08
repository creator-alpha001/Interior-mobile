// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_acknowledgement.freezed.dart';
part 'partner_acknowledgement.g.dart';

@Freezed()
abstract class PartnerAcknowledgement with _$PartnerAcknowledgement {
  const factory PartnerAcknowledgement({
    required String key,
    required String label,
  }) = _PartnerAcknowledgement;

  factory PartnerAcknowledgement.fromJson(Map<String, Object?> json) =>
      _$PartnerAcknowledgementFromJson(json);
}
