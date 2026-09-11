// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum VendorDocumentKind {
  @JsonValue('pan')
  pan('pan'),
  @JsonValue('gst_certificate')
  gstCertificate('gst_certificate'),
  @JsonValue('business_registration')
  businessRegistration('business_registration'),
  @JsonValue('signatory_id')
  signatoryId('signatory_id'),
  @JsonValue('address_proof')
  addressProof('address_proof'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const VendorDocumentKind(this.json);

  factory VendorDocumentKind.fromJson(String json) =>
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
  static List<VendorDocumentKind> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
