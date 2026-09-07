// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum PriceUnit {
  @JsonValue('per_piece')
  perPiece('per_piece'),
  @JsonValue('per_sqft')
  perSqft('per_sqft'),
  @JsonValue('per_running_ft')
  perRunningFt('per_running_ft'),
  @JsonValue('per_kg')
  perKg('per_kg'),
  @JsonValue('per_room')
  perRoom('per_room'),
  @JsonValue('per_project')
  perProject('per_project'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const PriceUnit(this.json);

  factory PriceUnit.fromJson(String json) => values.firstWhere(
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
  static List<PriceUnit> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
