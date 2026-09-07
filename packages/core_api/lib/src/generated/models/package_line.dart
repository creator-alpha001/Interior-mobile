// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import, unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_line.freezed.dart';
part 'package_line.g.dart';

@Freezed()
abstract class PackageLine with _$PackageLine {
  const factory PackageLine({
    required String label,
    required num quantity,
    required String? productId,
  }) = _PackageLine;
  
  factory PackageLine.fromJson(Map<String, Object?> json) => _$PackageLineFromJson(json);
}
