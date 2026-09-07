// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'city.dart';

part 'client_summary.freezed.dart';
part 'client_summary.g.dart';

@Freezed()
abstract class ClientSummary with _$ClientSummary {
  const factory ClientSummary({
    required String id,
    required String userId,
    required String name,
    required String mobile,
    required String? email,
    required City city,
    required String? address,
  }) = _ClientSummary;
  
  factory ClientSummary.fromJson(Map<String, Object?> json) => _$ClientSummaryFromJson(json);
}
