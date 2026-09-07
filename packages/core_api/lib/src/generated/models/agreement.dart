// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'agreement_status.dart';

part 'agreement.freezed.dart';
part 'agreement.g.dart';

@Freezed()
abstract class Agreement with _$Agreement {
  const factory Agreement({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String reference,
    required String leadId,
    required String clientId,
    required String professionalId,
    required int totalValue,
    required String paymentTerms,
    required AgreementStatus status,
    required String? documentUrl,
    required String? sentAt,
    required String? signedAt,
    required String? startDate,
    required String? cancelledReason,
  }) = _Agreement;
  
  factory Agreement.fromJson(Map<String, Object?> json) => _$AgreementFromJson(json);
}
