// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain_performance.dart';
import 'vendor_review.dart';

part 'vendor_performance.freezed.dart';
part 'vendor_performance.g.dart';

@Freezed()
abstract class VendorPerformance with _$VendorPerformance {
  const factory VendorPerformance({
    required List<DomainPerformance> byDomain,
    required num avgResponseHours,
    required int totalRevenue,
    required List<VendorReview> reviews,
  }) = _VendorPerformance;

  factory VendorPerformance.fromJson(Map<String, Object?> json) =>
      _$VendorPerformanceFromJson(json);
}
