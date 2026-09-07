// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'professional.dart';
import 'professional_domain_link.dart';

part 'vendor_dashboard.freezed.dart';
part 'vendor_dashboard.g.dart';

@Freezed()
abstract class VendorDashboard with _$VendorDashboard {
  const factory VendorDashboard({
    required Professional professional,
    required String displayName,
    required List<ProfessionalDomainLink> domains,
    required num newLeads,
    required num awaitingQuote,
    required num quotesOut,
    required num wonThisPeriod,
    required num liveProjects,
    required num visitsToday,
    required num commissionDue,
    required num commissionOverdue,
    required num unreadMessages,
  }) = _VendorDashboard;
  
  factory VendorDashboard.fromJson(Map<String, Object?> json) => _$VendorDashboardFromJson(json);
}
