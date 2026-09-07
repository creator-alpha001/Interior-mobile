// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'domain_labels_input.freezed.dart';
part 'domain_labels_input.g.dart';

@Freezed()
abstract class DomainLabelsInput with _$DomainLabelsInput {
  const factory DomainLabelsInput({
    required String materials,
    required String warranty,
    required String pricingBasis,
  }) = _DomainLabelsInput;
  
  factory DomainLabelsInput.fromJson(Map<String, Object?> json) => _$DomainLabelsInputFromJson(json);
}
