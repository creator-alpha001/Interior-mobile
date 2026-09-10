// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'city.dart';

part 'masked_client_summary.freezed.dart';
part 'masked_client_summary.g.dart';

@Freezed()
abstract class MaskedClientSummary with _$MaskedClientSummary {
  const factory MaskedClientSummary({
    required String displayName,
    required City? city,
    required String locality,
    required String? address,

    /// Always false.
    required bool contactReleased,
  }) = _MaskedClientSummary;

  factory MaskedClientSummary.fromJson(Map<String, Object?> json) =>
      _$MaskedClientSummaryFromJson(json);
}
