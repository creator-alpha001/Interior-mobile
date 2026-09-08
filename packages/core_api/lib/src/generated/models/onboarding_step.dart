// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'onboarding_step_key.dart';

part 'onboarding_step.freezed.dart';
part 'onboarding_step.g.dart';

@Freezed()
abstract class OnboardingStep with _$OnboardingStep {
  const factory OnboardingStep({
    required OnboardingStepKey key,
    required String label,
    required String description,
    required bool done,
    required bool blocking,
    required String? hint,
  }) = _OnboardingStep;

  factory OnboardingStep.fromJson(Map<String, Object?> json) =>
      _$OnboardingStepFromJson(json);
}
