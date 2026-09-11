// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'vendor_document_kind.dart';

part 'submit_vendor_document_body.freezed.dart';
part 'submit_vendor_document_body.g.dart';

@Freezed()
abstract class SubmitVendorDocumentBody with _$SubmitVendorDocumentBody {
  const factory SubmitVendorDocumentBody({
    required VendorDocumentKind kind,
    required List<String> files,
    String? documentNumber,
  }) = _SubmitVendorDocumentBody;

  factory SubmitVendorDocumentBody.fromJson(Map<String, Object?> json) =>
      _$SubmitVendorDocumentBodyFromJson(json);
}
