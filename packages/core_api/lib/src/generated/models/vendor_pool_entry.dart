// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'professional_summary.dart';

part 'vendor_pool_entry.freezed.dart';
part 'vendor_pool_entry.g.dart';

@Freezed()
abstract class VendorPoolEntry with _$VendorPoolEntry {
  const factory VendorPoolEntry({
    required ProfessionalSummary professional,
    required bool isAssigned,
    required bool isPreferred,
    required num activeLoad,
  }) = _VendorPoolEntry;
  
  factory VendorPoolEntry.fromJson(Map<String, Object?> json) => _$VendorPoolEntryFromJson(json);
}
