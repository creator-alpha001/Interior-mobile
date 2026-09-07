// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';
import 'lead_domain.dart';
import 'lead_domain_assignment.dart';
import 'lead_domain_item.dart';
import 'masked_client_summary.dart';
import 'material_source.dart';
import 'meeting.dart';
import 'quote.dart';

part 'vendor_lead_card.freezed.dart';
part 'vendor_lead_card.g.dart';

@Freezed()
abstract class VendorLeadCard with _$VendorLeadCard {
  const factory VendorLeadCard({
    required LeadDomainAssignment assignment,
    required LeadDomain leadDomain,
    required Domain domain,
    required String leadReference,
    required MaskedClientSummary client,
    required String description,
    required String urgency,
    required MaterialSource materialSource,
    required List<LeadDomainItem> items,
    required String? brief,
    required List<String> siteNotes,
    required int? budgetMax,
    required Quote? myQuote,
    required List<Meeting> visits,
    required num unreadMessages,
    required num competingQuotes,
    required bool won,
    required bool lost,
  }) = _VendorLeadCard;
  
  factory VendorLeadCard.fromJson(Map<String, Object?> json) => _$VendorLeadCardFromJson(json);
}
