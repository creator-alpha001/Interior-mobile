// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'portfolio_item.dart';
import 'vendor_achievement.dart';

part 'vendor_showcase.freezed.dart';
part 'vendor_showcase.g.dart';

@Freezed()
abstract class VendorShowcase with _$VendorShowcase {
  const factory VendorShowcase({
    required List<PortfolioItem> portfolio,
    required List<VendorAchievement> achievements,
  }) = _VendorShowcase;

  factory VendorShowcase.fromJson(Map<String, Object?> json) =>
      _$VendorShowcaseFromJson(json);
}
