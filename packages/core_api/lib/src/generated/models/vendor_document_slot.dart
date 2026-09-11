// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'media_asset.dart';
import 'vendor_document.dart';
import 'vendor_document_kind.dart';

part 'vendor_document_slot.freezed.dart';
part 'vendor_document_slot.g.dart';

@Freezed()
abstract class VendorDocumentSlot with _$VendorDocumentSlot {
  const factory VendorDocumentSlot({
    required VendorDocumentKind kind,
    required String label,
    required String description,

    /// The name has been replaced because it contains a keyword. Original name: `required`.
    @JsonKey(name: 'required') required bool requiredValue,
    required String? numberLabel,
    required VendorDocument? document,
    required List<MediaAsset> files,
  }) = _VendorDocumentSlot;

  factory VendorDocumentSlot.fromJson(Map<String, Object?> json) =>
      _$VendorDocumentSlotFromJson(json);
}
