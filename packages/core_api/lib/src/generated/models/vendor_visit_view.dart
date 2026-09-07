// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';
import 'masked_client_summary.dart';
import 'meeting.dart';

part 'vendor_visit_view.freezed.dart';
part 'vendor_visit_view.g.dart';

@Freezed()
abstract class VendorVisitView with _$VendorVisitView {
  const factory VendorVisitView({
    required Meeting meeting,
    required Domain domain,
    required MaskedClientSummary client,
    required String leadReference,
  }) = _VendorVisitView;
  
  factory VendorVisitView.fromJson(Map<String, Object?> json) => _$VendorVisitViewFromJson(json);
}
