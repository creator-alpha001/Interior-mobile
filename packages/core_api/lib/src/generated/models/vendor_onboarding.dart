// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'onboarding_step.dart';
import 'partner_agreement.dart';
import 'partner_terms.dart';

part 'vendor_onboarding.freezed.dart';
part 'vendor_onboarding.g.dart';

@Freezed()
abstract class VendorOnboarding with _$VendorOnboarding {
  const factory VendorOnboarding({
    required String professionalId,
    required List<OnboardingStep> steps,
    required int completedCount,
    required int totalCount,
    required bool canReceiveLeads,
    required String? blockedReason,
    required PartnerAgreement? agreement,
    required PartnerTerms terms,
  }) = _VendorOnboarding;

  factory VendorOnboarding.fromJson(Map<String, Object?> json) =>
      _$VendorOnboardingFromJson(json);
}
