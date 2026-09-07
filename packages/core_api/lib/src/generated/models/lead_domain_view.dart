// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'assignment_view.dart';
import 'domain.dart';
import 'lead_domain.dart';
import 'lead_domain_item.dart';
import 'meeting_view.dart';
import 'professional_summary.dart';
import 'quote_view.dart';

part 'lead_domain_view.freezed.dart';
part 'lead_domain_view.g.dart';

@Freezed()
abstract class LeadDomainView with _$LeadDomainView {
  const factory LeadDomainView({
    required LeadDomain leadDomain,
    required Domain domain,
    required List<AssignmentView> assignments,
    required List<QuoteView> quotes,
    required List<MeetingView> meetings,
    required List<LeadDomainItem> items,
    required ProfessionalSummary? selectedProfessional,
    required int unreadMessages,
  }) = _LeadDomainView;
  
  factory LeadDomainView.fromJson(Map<String, Object?> json) => _$LeadDomainViewFromJson(json);
}
