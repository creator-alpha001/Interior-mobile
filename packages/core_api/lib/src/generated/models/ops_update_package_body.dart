// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ops_update_package_body.freezed.dart';
part 'ops_update_package_body.g.dart';

@Freezed()
abstract class OpsUpdatePackageBody with _$OpsUpdatePackageBody {
  const factory OpsUpdatePackageBody({
    @Default('') String shortDescription,
    @Default('') String description,
    @Default(0) int durationDays,
    @Default([]) List<String> inclusions,
    @Default([]) List<String> exclusions,
    @Default(false) bool isFeatured,
    @Default([]) List<String> mediaIds,
    String? domainId,
    String? name,
    int? price,
    String? priceBasis,
    String? badge,
    bool? isActive,
  }) = _OpsUpdatePackageBody;

  factory OpsUpdatePackageBody.fromJson(Map<String, Object?> json) =>
      _$OpsUpdatePackageBodyFromJson(json);
}
