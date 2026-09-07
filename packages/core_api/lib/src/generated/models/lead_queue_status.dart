// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum LeadQueueStatus {
  @JsonValue('all')
  all('all'),
  /// The name has been replaced because it contains a keyword. Original name: `new`.
  @JsonValue('new')
  valueNew('new'),
  @JsonValue('verified')
  verified('verified'),
  @JsonValue('in_progress')
  inProgress('in_progress'),
  @JsonValue('closed')
  closed('closed'),
  @JsonValue('archived')
  archived('archived'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const LeadQueueStatus(this.json);

  factory LeadQueueStatus.fromJson(String json) => values.firstWhere(
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
  static List<LeadQueueStatus> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
