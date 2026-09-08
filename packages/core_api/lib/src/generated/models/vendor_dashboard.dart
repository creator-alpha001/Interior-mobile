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
    required int newLeads,
    required int awaitingQuote,
    required int quotesOut,
    required int wonThisPeriod,
    required int liveProjects,
    required int visitsToday,
    required int commissionDue,
    required int commissionOverdue,
    required int unreadMessages,
  }) = _VendorDashboard;

  factory VendorDashboard.fromJson(Map<String, Object?> json) =>
      _$VendorDashboardFromJson(json);
}
