// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum PermissionKey {
  /// Incorrect name has been replaced. Original name: `leads.view`.
  @JsonValue('leads.view')
  undefined0('leads.view'),

  /// Incorrect name has been replaced. Original name: `leads.manage`.
  @JsonValue('leads.manage')
  undefined1('leads.manage'),

  /// Incorrect name has been replaced. Original name: `vendors.view`.
  @JsonValue('vendors.view')
  undefined2('vendors.view'),

  /// Incorrect name has been replaced. Original name: `vendors.verify`.
  @JsonValue('vendors.verify')
  undefined3('vendors.verify'),

  /// Incorrect name has been replaced. Original name: `agreements.view`.
  @JsonValue('agreements.view')
  undefined4('agreements.view'),

  /// Incorrect name has been replaced. Original name: `agreements.manage`.
  @JsonValue('agreements.manage')
  undefined5('agreements.manage'),

  /// Incorrect name has been replaced. Original name: `commission.view`.
  @JsonValue('commission.view')
  undefined6('commission.view'),

  /// Incorrect name has been replaced. Original name: `commission.manage`.
  @JsonValue('commission.manage')
  undefined7('commission.manage'),

  /// Incorrect name has been replaced. Original name: `catalog.manage`.
  @JsonValue('catalog.manage')
  undefined8('catalog.manage'),

  /// Incorrect name has been replaced. Original name: `blog.manage`.
  @JsonValue('blog.manage')
  undefined9('blog.manage'),

  /// Incorrect name has been replaced. Original name: `reports.view`.
  @JsonValue('reports.view')
  undefined10('reports.view'),

  /// Incorrect name has been replaced. Original name: `settings.manage`.
  @JsonValue('settings.manage')
  undefined11('settings.manage'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const PermissionKey(this.json);

  factory PermissionKey.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError(
        'Cannot convert enum value with null JSON representation to String. '
        'This usually happens for \$unknown or @JsonValue(null) entries.',
      );
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<PermissionKey> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
