// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'vendor_document_kind.dart';
import 'vendor_document_status.dart';

part 'vendor_document.freezed.dart';
part 'vendor_document.g.dart';

@Freezed()
abstract class VendorDocument with _$VendorDocument {
  const factory VendorDocument({
    required String createdAt,
    required String updatedAt,
    required String? deletedAt,
    required String id,
    required String professionalId,
    required VendorDocumentKind kind,
    required String? documentNumber,
    required VendorDocumentStatus status,
    required String submittedAt,
    required String? reviewedAt,
    required String? reviewedByUserId,
    required String? reviewNote,
  }) = _VendorDocument;

  factory VendorDocument.fromJson(Map<String, Object?> json) =>
      _$VendorDocumentFromJson(json);
}
