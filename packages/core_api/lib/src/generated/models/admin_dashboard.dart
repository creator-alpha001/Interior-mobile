// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_totals.dart';
import 'city_slice.dart';
import 'domain_slice.dart';

part 'admin_dashboard.freezed.dart';
part 'admin_dashboard.g.dart';

@Freezed()
abstract class AdminDashboard with _$AdminDashboard {
  const factory AdminDashboard({
    required AdminTotals totals,
    required List<DomainSlice> byDomain,
    required List<CitySlice> byCity,
  }) = _AdminDashboard;
  
  factory AdminDashboard.fromJson(Map<String, Object?> json) => _$AdminDashboardFromJson(json);
}
