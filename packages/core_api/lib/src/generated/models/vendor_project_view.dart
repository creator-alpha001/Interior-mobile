// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';
import 'masked_client_summary.dart';
import 'project.dart';
import 'review.dart';

part 'vendor_project_view.freezed.dart';
part 'vendor_project_view.g.dart';

@Freezed()
abstract class VendorProjectView with _$VendorProjectView {
  const factory VendorProjectView({
    required Project project,
    required Domain domain,
    required MaskedClientSummary client,
    required String cityName,
    required Review? review,
  }) = _VendorProjectView;

  factory VendorProjectView.fromJson(Map<String, Object?> json) =>
      _$VendorProjectViewFromJson(json);
}
