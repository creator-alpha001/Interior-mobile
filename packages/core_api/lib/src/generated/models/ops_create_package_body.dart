// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ops_create_package_body.freezed.dart';
part 'ops_create_package_body.g.dart';

@Freezed()
abstract class OpsCreatePackageBody with _$OpsCreatePackageBody {
  const factory OpsCreatePackageBody({
    required String domainId,
    required String name,
    required int price,
    required String priceBasis,
    String? badge,
    @Default('') String shortDescription,
    @Default('') String description,
    @Default(0) int durationDays,
    @Default([]) List<String> inclusions,
    @Default([]) List<String> exclusions,
    @Default(false) bool isFeatured,
    @Default([]) List<String> mediaIds,
  }) = _OpsCreatePackageBody;

  factory OpsCreatePackageBody.fromJson(Map<String, Object?> json) =>
      _$OpsCreatePackageBodyFromJson(json);
}
