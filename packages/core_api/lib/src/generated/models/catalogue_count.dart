// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalogue_count.freezed.dart';
part 'catalogue_count.g.dart';

@Freezed()
abstract class CatalogueCount with _$CatalogueCount {
  const factory CatalogueCount({
    required String domainId,
    required int products,
    required int packages,
  }) = _CatalogueCount;

  factory CatalogueCount.fromJson(Map<String, Object?> json) =>
      _$CatalogueCountFromJson(json);
}
