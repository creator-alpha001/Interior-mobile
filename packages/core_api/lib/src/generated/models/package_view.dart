// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

import 'domain.dart';
import 'package_line.dart';
import 'service_package.dart';

part 'package_view.freezed.dart';
part 'package_view.g.dart';

@Freezed()
abstract class PackageView with _$PackageView {
  const factory PackageView({
    required ServicePackage servicePackage,
    required Domain domain,
    required List<PackageLine> items,
  }) = _PackageView;
  
  factory PackageView.fromJson(Map<String, Object?> json) => _$PackageViewFromJson(json);
}
