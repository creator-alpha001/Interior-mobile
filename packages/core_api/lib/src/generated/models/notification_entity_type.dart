// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum NotificationEntityType {
  @JsonValue('lead')
  lead('lead'),
  @JsonValue('lead_domain')
  leadDomain('lead_domain'),
  @JsonValue('quote')
  quote('quote'),
  @JsonValue('meeting')
  meeting('meeting'),
  @JsonValue('agreement')
  agreement('agreement'),
  @JsonValue('project')
  project('project'),
  @JsonValue('invoice')
  invoice('invoice'),
  @JsonValue('message')
  message('message'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const NotificationEntityType(this.json);

  factory NotificationEntityType.fromJson(String json) => values.firstWhere(
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
  static List<NotificationEntityType> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
