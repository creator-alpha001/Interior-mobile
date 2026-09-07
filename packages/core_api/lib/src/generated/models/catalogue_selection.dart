// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalogue_selection.freezed.dart';
part 'catalogue_selection.g.dart';

@Freezed()
abstract class CatalogueSelection with _$CatalogueSelection {
  const factory CatalogueSelection({
    required String domainId,
    required String itemName,
    required int quantity,
    String? productId,
    String? packageId,
    Map<String, String>? selectedOptions,
    int? indicativePrice,
    String? notes,
  }) = _CatalogueSelection;
  
  factory CatalogueSelection.fromJson(Map<String, Object?> json) => _$CatalogueSelectionFromJson(json);
}
