// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum OnboardingStepKey {
  @JsonValue('profile')
  profile('profile'),
  @JsonValue('identity')
  identity('identity'),
  @JsonValue('trades')
  trades('trades'),
  @JsonValue('service_areas')
  serviceAreas('service_areas'),
  @JsonValue('portfolio')
  portfolio('portfolio'),
  @JsonValue('agreement')
  agreement('agreement'),
  @JsonValue('bank')
  bank('bank'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const OnboardingStepKey(this.json);

  factory OnboardingStepKey.fromJson(String json) => values.firstWhere(
        (e) => e.json == json,
        orElse: () => $unknown,
      );

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError('Cannot convert enum value with null JSON representation to String. '
          'This usually happens for \$unknown or @JsonValue(null) entries.');
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();
  /// Returns all defined enum values excluding the $unknown value.
  static List<OnboardingStepKey> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
