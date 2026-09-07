// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_totals.freezed.dart';
part 'admin_totals.g.dart';

@Freezed()
abstract class AdminTotals with _$AdminTotals {
  const factory AdminTotals({
    required num leads,
    required num activeLeads,
    required num vendors,
    required num pendingVerification,
    required num revenue,
    required num commissionBilled,
    required num commissionPending,
    required num commissionOverdue,
    required num openTickets,
  }) = _AdminTotals;
  
  factory AdminTotals.fromJson(Map<String, Object?> json) => _$AdminTotalsFromJson(json);
}
