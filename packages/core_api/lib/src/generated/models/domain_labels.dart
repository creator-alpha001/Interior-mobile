// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain_labels.freezed.dart';
part 'domain_labels.g.dart';

@Freezed()
abstract class DomainLabels with _$DomainLabels {
  const factory DomainLabels({
    required String materials,
    required String warranty,
    required String pricingBasis,
  }) = _DomainLabels;

  factory DomainLabels.fromJson(Map<String, Object?> json) =>
      _$DomainLabelsFromJson(json);
}
